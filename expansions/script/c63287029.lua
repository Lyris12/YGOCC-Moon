--Escaped Alien Prisoner
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetTarget(cid.cttg)
	e1:SetOperation(cid.ctop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
	--counter effects
	local ct1=Effect.CreateEffect(c)
	ct1:SetType(EFFECT_TYPE_FIELD)
	ct1:SetCode(EFFECT_UPDATE_ATTACK)
	ct1:SetRange(LOCATION_MZONE)
	ct1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	ct1:SetCondition(cid.adcon)
	ct1:SetTarget(cid.adtg)
	ct1:SetValue(cid.adval)
	c:RegisterEffect(ct1)
	local ct2=ct1:Clone()
	ct2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(ct2)
end
--COUNTER
function cid.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x100e,1) end
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x100e,1)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x100e,1)
end
function cid.ctop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x100e,1)
	local tc=g:GetFirst()
	if tc and tc:IsFaceup() then
		Duel.HintSelection(g)
		tc:AddCounter(0x100e,1)
	end
end
--SPSUMMON EFFECT
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--COUNTER EFFECTS
function cid.adcon(e)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
function cid.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
function cid.adval(e,c)
	return c:GetCounter(0x100e)*-300
end