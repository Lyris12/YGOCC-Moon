--Muscwole Ultrabrawn
local cid,id=GetID()
function cid.initial_effect(c)
	--cannot be target
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetValue(cid.efilter)
	c:RegisterEffect(e7)
	--special summon
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,id)
	e0:SetCondition(cid.spcon)
	e0:SetCost(cid.spcost)
	e0:SetTarget(cid.sptg)
	e0:SetOperation(cid.spop)
	c:RegisterEffect(e0)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetCondition(cid.atk(2300))
	e1:SetValue(cid.indesval)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id+10000)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cid.negcon)
	e3:SetTarget(cid.distg)
	e3:SetOperation(cid.disop)
	c:RegisterEffect(e3)
	--cannot negate
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(cid.disableable)
	c:RegisterEffect(e4)
end
function cid.efilter(e,re,rp)
	return re:GetHandler():IsType(TYPE_EQUIP) and not re:GetHandler():IsSetCard(0x777)
end
function cid.atk(val)
	return function(e)
		return e:GetHandler():IsAttackAbove(val)
	end
end
function cid.spcon(e,tp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function cid.rfilter(c)
	return c:IsSetCard(0x777) and c:IsAbleToRemoveAsCost()
end
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) end
	if e:GetHandler():IsAttackAbove(3700) and e:GetHandler():IsHasEffect(id) then
		local flag=e:GetProperty()
		if flag&EFFECT_FLAG_CANNOT_DISABLE==0 then e:SetProperty(flag+EFFECT_FLAG_CANNOT_DISABLE) end
	else
		local flag=e:GetProperty()
		if flag&EFFECT_FLAG_CANNOT_DISABLE~=0 then e:SetProperty(flag-EFFECT_FLAG_CANNOT_DISABLE) end
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end
--EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE
function cid.indesval(e)
	if e:GetHandler():IsAttackAbove(3700) and e:GetHandler():IsHasEffect(id) then
		return true
	else
		return not e:GetHandler():IsDisabled()
	end
end
function cid.disableable(e)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 then
		if c:IsDisabled() then
			return false
		else
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
	if not c:IsHasEffect(id) then
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(id)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e4)
	end
end
function cid.negcon(e,tp,eg,ep,ev,re,r,rp)
    --return function(e)
	if not e:GetHandler():IsAttackAbove(3000) then return false end
	local ph=Duel.GetCurrentPhase()
	return (ph>PHASE_MAIN1 and ph<PHASE_MAIN2) and rp==1-tp and Duel.GetTurnPlayer()==tp
end
