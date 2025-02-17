function OUT = get_quantalsize_TEST(fname)


[im,metadata]=mpqc.tools.scanImage_stackLoad(fname,false); %Do not subtract the offset

nChans = length(metadata.channelSave);

for ii=1:nChans

	tChan = im(:,:,ii:nChans:end);
	OUT(ii) = mpqc.tools.compute_quantalsize(tChan);
	OUT(ii).details=sprintf('channel %d',metadata.channelSave(ii));
end