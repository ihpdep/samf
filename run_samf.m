function results = run_samf(seq, res_path, bSaveImage)

	%default settings
	video = 'benchmark'; 
	 kernel_type = 'gaussian'; 
	 feature_type = 'hogcolor'; 



	%parameters according to the paper. at this point we can override
	%parameters based on the chosen kernel or feature type
	kernel.type = kernel_type;
	
	features.gray = false;
	features.hog = false;
    features.hogcolor = false;
	
	padding = 1.5;  %extra area surrounding the target
	lambda = 1e-4;  %regularization
	output_sigma_factor = 0.1;  %spatial bandwidth (proportional to target)
	
	switch feature_type
	case 'gray',
		interp_factor = 0.075;  %linear interpolation factor for adaptation

		kernel.sigma = 0.2;  %gaussian kernel bandwidth
		
		kernel.poly_a = 1;  %polynomial kernel additive term
		kernel.poly_b = 7;  %polynomial kernel exponent
	
		features.gray = true;
		cell_size = 1;
		
	case 'hog',
		interp_factor = 0.015;%0.02
		
		kernel.sigma = 0.5;
		
		kernel.poly_a = 1;
		kernel.poly_b = 9;
		
		features.hog = true;
		features.hog_orientations = 9;
		cell_size = 4;
	case 'hogcolor',
		interp_factor = 0.01;
		
		kernel.sigma = 0.5;
		
		kernel.poly_a = 1;
		kernel.poly_b = 9;
		
		features.hogcolor = true;
		features.hog_orientations = 9;
		cell_size = 4;	
	otherwise
		error('Unknown feature.')
	end
	%running in benchmark mode - this is meant to interface easily
		%with the benchmark's code.
		
		%get information (image file names, initial position, etc) from
		%the benchmark's workspace variables
		seq = evalin('base', 'subS');
		target_sz = seq.init_rect(1,[4,3]);
		pos = seq.init_rect(1,[2,1]) + floor(target_sz/2);
		img_files = seq.s_frames;
		video_path = [];
		
		%call tracker function with all the relevant parameters
		[positions,rect_results,t]= tracker(video_path, img_files, pos, target_sz, ...
			padding, kernel, lambda, output_sigma_factor, interp_factor, ...
			cell_size, features, 0);
		
		%return results to benchmark, in a workspace variable
		rects =rect_results;
%         [positions(:,2) - target_sz(2)/2, positions(:,1) - target_sz(1)/2];
% 		rects(:,3) = target_sz(2);
% 		rects(:,4) = target_sz(1);
		results.type = 'rect';
		results.res = rects;

	results.fps = numel(img_files) /t;
	results.type='rect';
end