require 'test/helper'

class Dummy
  # This is a dummy class
end

class AttachmentTest < Test::Unit::TestCase
  context "Attachment default_options" do
    setup do
      rebuild_model
      @old_default_options = Paperclip::Attachment.default_options.dup
      @new_default_options = @old_default_options.merge({
        :path => "argle/bargle",
        :url => "fooferon",
        :default_url => "not here.png"
      })
    end

    teardown do
      Paperclip::Attachment.default_options.merge! @old_default_options
    end

    should "be overrideable" do
      Paperclip::Attachment.default_options.merge!(@new_default_options)
      @new_default_options.keys.each do |key|
        assert_equal @new_default_options[key],
                     Paperclip::Attachment.default_options[key]
      end
    end

    context "on an Attachment" do
      setup do
        @dummy = Dummy.new
        @attachment = @dummy.avatar
      end

      Paperclip::Attachment.default_options.keys.each do |key|
        should "be the default_options for #{key}" do
          assert_equal @old_default_options[key], 
                       @attachment.instance_variable_get("@#{key}"),
                       key
        end
      end

      context "when redefined" do
        setup do
          Paperclip::Attachment.default_options.merge!(@new_default_options)
          @dummy = Dummy.new
          @attachment = @dummy.avatar
        end

        Paperclip::Attachment.default_options.keys.each do |key|
          should "be the new default_options for #{key}" do
            assert_equal @new_default_options[key],
                         @attachment.instance_variable_get("@#{key}"),
                         key
          end
        end
      end
    end
  end

  context "An attachment" do
    setup do
      Paperclip::Attachment.default_options.merge!({
        :path => ":rails_root/tmp/:attachment/:class/:style/:id/:basename.:extension"
      })
      @instance = stub
      @instance.stubs(:id).returns(41)
      @instance.stubs(:class).returns(Dummy)
      @instance.stubs(:[]).with(:test_file_name).returns("5k.png")
      @instance.stubs(:[]).with(:test_content_type).returns("image/png")
      @instance.stubs(:[]).with(:test_file_size).returns(12345)
      @attachment = Paperclip::Attachment.new(:test,
                                              @instance)
      @file = File.new(File.join(File.dirname(__FILE__),
                                 "fixtures",
                                 "5k.png"))
    end

    should "return its default_url when no file assigned" do
      assert @attachment.file.nil?
      assert_equal "/tests/original/missing.png", @attachment.url
      assert_equal "/tests/blah/missing.png", @attachment.url(:blah)
    end

    context "when expecting three styles" do
      setup do
        styles = {:styles => { :large  => ["400x400", :png],
                               :medium => ["100x100", :gif],
                               :small => ["32x32#", :jpg]}}
        @attachment = Paperclip::Attachment.new(:test,
                                                @instance,
                                                styles)
      end

      context "and assigned a file" do
        setup do
          @instance.expects(:[]=).with(:test_file_name,
                                       File.basename(@file.path))
          @instance.expects(:[]=).with(:test_content_type, "image/png")
          @instance.expects(:[]=).with(:test_file_size, @file.size)
          @instance.expects(:[]=).with(:test_file_name, nil)
          @instance.expects(:[]=).with(:test_content_type, nil)
          @instance.expects(:[]=).with(:test_file_size, nil)
          @attachment.assign(@file)
        end

        should "return the real url" do
          assert @attachment.file
          assert_equal "/tests/41/original/5k.png", @attachment.url
          assert_equal "/tests/41/blah/5k.png", @attachment.url(:blah)
        end

        should "be dirty" do
          assert @attachment.dirty?
        end

        should "have its image and attachments as tempfiles" do
          [nil, :large, :medium, :small].each do |style|
            assert File.exists?(@attachment.to_io(style))
          end
        end

        context "and saved" do
          setup do
            @attachment.save
          end

          should "commit the files to disk" do
            [nil, :large, :medium, :small].each do |style|
              io = @attachment.to_io(style)
              assert File.exists?(io)
              assert ! io.is_a?(::Tempfile)
            end
          end

          should "save the files as the right formats and sizes" do
            [[:large, 400, 61, "PNG"],
             [:medium, 100, 15, "GIF"],
             [:small, 32, 32, "JPEG"]].each do |style|
              cmd = "identify -format '%w %h %b %m' " + 
                    "#{@attachment.to_io(style.first).path}"
              out = `#{cmd}`
              width, height, size, format = out.split(" ")
              assert_equal style[1].to_s, width.to_s 
              assert_equal style[2].to_s, height.to_s
              assert_equal style[3].to_s, format.to_s
            end
          end

          should "have #file be equal #to_io(:original)" do
            assert_equal @attachment.file, @attachment.to_io(:original)
          end

          should "still have its #file attribute not be nil" do
            assert ! @attachment.file.nil?
          end
        end
      end
    end

    context "when trying a nonexistant storage type" do
      setup do
        rebuild_model :storage => :not_here
      end

      should "not be able to find the module" do
        assert_raise(NameError){ Dummy.new.avatar }
      end
    end
  end
end
