--Silvva, Guardian of Eternna
function c213030.initial_effect(c)
	--summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(213030,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,213030)
	e1:SetTarget(c213030.sumtg)
	e1:SetOperation(c213030.sumop)
	c:RegisterEffect(e1)
 	--level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(213030,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,213031)
	e2:SetTarget(c213030.lvtg)
	e2:SetOperation(c213030.lvop)
	c:RegisterEffect(e2)
end
function c213030.sumfilter(c)
	return c:IsSetCard(0x2700) and c:IsSummonable(true,nil)
end
function c213030.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c213030.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function c213030.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,c213030.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end
function c213030.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2700) and c:IsLevelAbove(1)
end
function c213030.lvfilter1(c,tp)
	return c213030.lvfilter(c) and Duel.IsExistingMatchingCard(c213030.lvfilter2,tp,LOCATION_MZONE,0,1,c,c:GetLevel())
end
function c213030.lvfilter2(c,lv)
	return c213030.lvfilter(c) and not c:IsLevel(lv)
end
function c213030.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c213030.lvfilter1(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c213030.lvfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c213030.lvfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function c213030.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local lv=tc:GetLevel()
	local g=Duel.GetMatchingGroup(c213030.lvfilter,tp,LOCATION_MZONE,0,nil)
	local lc=g:GetFirst()
	while lc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		lc:RegisterEffect(e1)
		lc=g:GetNext()
	end
end

