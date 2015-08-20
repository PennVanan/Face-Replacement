Nick Iodice
Alagiavanan Saravanan
December 19, 2014
CIS 581, README for final project


In order for this code to run, the file structure must remain exactly as it is.
You must also have a valid C compiler on your system. Here is some info for the
TAs:

    1. Generate image submissions: generate_final_submssion_images.m
        This script does the following:
            A. Compiles the face detection software
            B. Finds the source faces specified. By default, this is
            'source_faces/nick' but it can be changed to 'source_faces/vanan'
            to swap Vanan's face into the image rather than Nick's
            C. Replaces each of the test images under 'OfficialTestSet/*' and
            saves them to 'final_outputs/face_swaps'
            D. Creates the 'Spiffify' video and saves it to
            'final_outputs/eternal_glory.avi' (do note that this takes a long
            time!)

    2. Submitted output images:
        'final_outputs/face_swaps/nick'
        'final_outputs/face_swaps/vanan_face_hi_res'
        'final_outputs/face_swaps/vanan_face_low_res'

    3. Spiffify videos:
        a) 'final_outputs/submitted_eternal_glory_1.avi' -- one face used in
        all frames
        b) 'final_outputs/submitted_eternal_glory_2.avi' -- two different faces
        used in each frame

    4. Spiffify video frames:
        'target_faces/'

    4. Face detection software:
        face-release1.0-basic/

    5. Compile face detection software: Run
        cd 'face-release1.0-basic'
        compile

    6. Official Test Set
        'OfficialTestSet/'

    7. Checkpoint and final presentation PDFs / PPTs
        'turned_in'