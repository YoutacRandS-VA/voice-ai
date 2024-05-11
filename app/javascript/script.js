const textarea = document.querySelector('textarea');
const characterCount = document.querySelector('.character-count');
const sendBtn = document.querySelector('.send-btn');
const voiceItems = document.querySelectorAll('.voice-item');
const errorMessage = document.querySelector('.error-message');

let selectedSpeakerId = null;

textarea.addEventListener('input', () => {
  const text = textarea.value;
  const filteredText = text.replace(/[^a-zA-Z\s]/g, '');
  
  if (text !== filteredText) {
    textarea.value = filteredText;
    errorMessage.textContent = 'حاليًا لا ندعم إلا النص الإنجليزي';
  } else {
    errorMessage.textContent = '';
  }
  
  const length = textarea.value.length;
  characterCount.textContent = `عدد الأحرف: ${length}`;
});

voiceItems.forEach(item => {
  item.addEventListener('click', () => {
    voiceItems.forEach(item => item.classList.remove('selected'));
    item.classList.add('selected');
    selectedSpeakerId = item.getAttribute('data-speaker-id');
  });
});

sendBtn.addEventListener('click', () => {
  const text = textarea.value;
  const characterLimit = 500;

  if (text.trim() !== '' && selectedSpeakerId !== null) {
    if (text.length <= characterLimit) {
      sendToController(text, selectedSpeakerId);
      textarea.value = '';
      characterCount.textContent = 'عدد الأحرف: 0';
      errorMessage.textContent = '';
    } else {
      errorMessage.textContent = `تجاوزت الحد الأقصى للأحرف المسموح به وهو ${characterLimit} حرفًا.`;
    }
  } else {
    errorMessage.textContent = 'الرجاء إدخال نص وتحديد متحدث قبل الإرسال.';
  }
});

// تعديل الدالة sendToController
function sendToController(text, speakerId) {
  const requestData = {
    text: text,
    speaker_id: speakerId
  };

  // إظهار علامة التحميل وإخفاء المتحدثين وعنوان "اختر صوتًا"
  document.querySelector('.loading-spinner').style.display = 'block';
  document.querySelector('.voice-grid').style.display = 'none';
  document.querySelector('.section-header').style.display = 'none';

  fetch('/generate_speech', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    },
    body: JSON.stringify(requestData)
  })
  .then(response => {
    if (response.ok) {
      return response.json();
    } else {
      throw new Error('حدث خطأ أثناء إرسال الطلب.');
    }
  })
  .then(data => {
    // إخفاء علامة التحميل
    document.querySelector('.loading-spinner').style.display = 'none';

    // عرض زر التنزيل
    const audioContainer = document.querySelector('.audio-container');
    const downloadBtn = document.querySelector('#download-btn');

    downloadBtn.href = data.mp3_url;
    audioContainer.style.display = 'block';
  })
  .catch(error => {
    console.error('حدث خطأ:', error);
    // إخفاء علامة التحميل وإظهار رسالة الخطأ
    document.querySelector('.loading-spinner').style.display = 'none';
    document.querySelector('.voice-grid').style.display = 'grid';
    document.querySelector('.section-header').style.display = 'block';
    errorMessage.textContent = 'حدث خطأ أثناء إنشاء الصوت. يرجى المحاولة مرة أخرى.';
  });
}