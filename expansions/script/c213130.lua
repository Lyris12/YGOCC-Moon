--Worm Lemniscate
function c213130.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep2(c,c213130.ffilter,2,63,true)
	--summon success
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c213130.matcheck)
	c:RegisterEffect(e2)
end
function c213130.ffilter(c,fc)
	return c:IsRace(RACE_REPTILE)
end
function c213130.matcheck(e,c)
	local ct=c:GetMaterial():GetClassCount(Card.GetCode)
	if ct>0 then
		local ae=Effect.CreateEffect(c)
		ae:SetType(EFFECT_TYPE_SINGLE)
		ae:SetCode(EFFECT_SET_ATTACK)
		ae:SetValue(ct*800)
		ae:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(ae)
	end
	if ct>=2 then
		local e1=Effect.CreateEffect(c)
       	e1:SetType(EFFECT_TYPE_SINGLE)
	       e1:SetCode(EFFECT_ATTACK_ALL)
	       e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1)
	end
	if ct>=3 then
		local e1=Effect.CreateEffect(c)
	       e1:SetDescription(aux.Stringid(213130,0))
	       e1:SetType(EFFECT_TYPE_QUICK_O)
	       e1:SetCode(EVENT_CHAINING)
	       e1:SetRange(LOCATION_MZONE)
	       e1:SetCountLimit(1)
		e1:SetCondition(c213130.poscon)
		e1:SetTarget(c213130.postg)
		e1:SetOperation(c213130.posop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	       c:RegisterEffect(e1)
	end
	if ct>=4 then
	      local e1=Effect.CreateEffect(c)
	      e1:SetDescription(aux.Stringid(213130,1))
	      e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	      e1:SetType(EFFECT_TYPE_IGNITION)
	      e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	      e1:SetRange(LOCATION_MZONE)
	      e1:SetCountLimit(1)
	      e1:SetTarget(c213130.sptg)
	      e1:SetOperation(c213130.spop)
	      e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	       c:RegisterEffect(e1)
	end
	if ct>=5 then
	      local e1=Effect.CreateEffect(c)
	      e1:SetDescription(aux.Stringid(213130,2))
	      e1:SetCategory(CATEGORY_CONTROL)
	      e1:SetType(EFFECT_TYPE_IGNITION)
	      e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	      e1:SetRange(LOCATION_MZONE)
	      e1:SetCountLimit(1)
	      e1:SetTarget(c213130.cttg)
	      e1:SetOperation(c213130.ctop)
	      e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	       c:RegisterEffect(e1)
	end
end
function c213130.poscon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
function c213130.posfilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsRace(RACE_REPTILE) and c:IsCanChangePosition()
end
function c213130.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c213130.posfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function c213130.posop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,c213130.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
function c213130.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function c213130.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c213130.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingTarget(c213130.spfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler(),e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c213130.spfilter,tp,LOCATION_GRAVE,0,2,2,e:GetHandler(),e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
function c213130.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if ft<2 or g:GetCount()~=2 then return end
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function c213130.ctfilter(c)
	return c:IsControlerCanBeChanged()
end
function c213130.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c213130.ctfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c213130.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,c213130.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function c213130.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
	end
end