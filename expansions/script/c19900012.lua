--Geneseed Buttercherry
local cid,id=GetID()
function cid.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(cid.spcon)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(cid.sptg2)
	e2:SetOperation(cid.spop2)
	c:RegisterEffect(e2)
end
function cid.xfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x57b) and not c:IsCode(id)
end  
function cid.atkfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_EVOLUTE)
end
function cid.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
	Duel.IsExistingMatchingCard(cid.xfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function cid.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cid.atkfilter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.atkfilter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cid.atkfilter2,tp,LOCATION_MZONE,0,1,1,nil)
end
function cid.spop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end