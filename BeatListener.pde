class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioInput source; //change from audioplayer since we are not using it
  
  BeatListener(BeatDetect beat, AudioInput source) //as above
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }
  
  void samples(float[] samps)
  {
    beat.detect(source.mix);
  }
  
  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
  }
}
