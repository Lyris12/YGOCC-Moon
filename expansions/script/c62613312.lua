--Karasu, la Nottesfumata
--Script by XGlitchy30
function c62613312.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,c62613312.lcheck)
	c:EnableReviveLimit()
	--Attribute
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e0)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62613312,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,62613312)
	e1:SetCondition(c62613312.spcon)
	e1:SetCost(c62613312.spcost)
	e1:SetTarget(c62613312.sptg)
	e1:SetOperation(c62613312.spop)
	c:RegisterEffect(e1)
	--ATK boost
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62613312,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1,62613312)
	e2:SetCondition(c62613312.atkcon)
	e2:SetCost(c62613312.atkcost)
	e2:SetOperation(c62613312.atkop)
	c:RegisterEffect(e2)
end
--filters
function c62613312.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x6233)
end
function c62613312.lcheck(g,lc)
	return g:IsExists(c62613312.matfilter,1,nil)
end
function c62613312.cfilter(c,e,tp)
	return c:IsSetCard(0x6233) and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(c62613312.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp,c:GetCode()) 
end
function c62613312.spfilter(c,e,tp,code)
	return c:IsSetCard(0x6233) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and not c:IsCode(code)
end
function c62613312.atkfilter(c)
	return c:IsSetCard(0x6233) and c:IsType(TYPE_MONSTER) and c:GetAttack()>0 and c:IsAbleToRemoveAsCost()
end
--special summon
function c62613312.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c62613312.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function c62613312.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c62613312.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c62613312.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		e:SetLabelObject(g:GetFirst())
	end
	local g2=Duel.GetMatchingGroup(c62613312.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp,e:GetLabelObject():GetCode())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
function c62613312.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c62613312.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetLabelObject():GetCode())
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c62613312.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c62613312.splimit(e,c)
	return not c:IsSetCard(0x6233)
end
--ATK boost
function c62613312.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	return tc and tc:IsControler(tp) and tc:IsSetCard(0x6233) and tc:IsRelateToBattle()
end
function c62613312.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c62613312.atkfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c62613312.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetAttack())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c62613312.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(math.ceil(e:GetLabel()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
	end
end