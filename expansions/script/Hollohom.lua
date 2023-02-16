--Hollohom Commons

Hollohom=Hollohom or {}

Hollohom.Code = 0x253
Hollohom.ID = 28940100
function Hollohom.Is(c, ignore_facedown)
	if (ignore_facedown==nil) then ignore_facedown=false end
	return c:IsSetCard(Hollohom.Code) and (ignore_facedown or (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED+LOCATION_ONFIELD)))
end

function Hollohom.FieldCheck(tp)
	return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_FZONE,1,nil) and not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_FZONE,0,1,nil)
end

function Hollohom.EnableUnion(c,op)
	local code=c:GetOriginalCode()
	aux.EnableUnionAttribute(c,Hollohom.EquipLimit)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(Hollohom.ID,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(Hollohom.EquipTarget)
	e1:SetOperation(Hollohom.EquipOperation)
	c:RegisterEffect(e1)
	--unequip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(Hollohom.ID,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(Hollohom.UnequipTarget)
	e2:SetOperation(Hollohom.UnequipOperation)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetDescription(aux.Stringid(Hollohom.ID,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,{code,1})
	e3:SetCondition(function(e,tp) return Duel.IsEnvironment(Hollohom.ID,tp) end)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(Hollohom.ID,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1,{code,1})
	e4:SetCondition(function(e,tp) return Duel.IsEnvironment(Hollohom.ID,tp) end)
	c:RegisterEffect(e4)
	--Bonus
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CUSTOM+Hollohom.ID)
	e5:SetOperation(op)
	c:RegisterEffect(e5)
end
function Hollohom.EquipLimit(e,c)
	return c:IsType(TYPE_PENDULUM) or e:GetHandler():GetEquipTarget()==c
end
function Hollohom.EquipFilter(c)
	local ct1,ct2=c:GetUnionCount()
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and ct2==0
end
function Hollohom.EquipTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and Hollohom.EquipFilter(chkc) end
	if chk==0 then return c:GetFlagEffect(Hollohom.Code)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(Hollohom.EquipFilter,tp,LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,Hollohom.EquipFilter,tp,LOCATION_MZONE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	c:RegisterFlagEffect(Hollohom.Code,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
function Hollohom.EquipOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not Hollohom.EquipFilter(tc) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	if not Duel.Equip(tp,c,tc,false) then return end
	aux.SetUnionState(c)
	Duel.RaiseSingleEvent(c,EVENT_CUSTOM+Hollohom.ID,e,r,rp,tp,0)
end
function Hollohom.UnequipTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(Hollohom.Code)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:GetEquipTarget() and c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:RegisterFlagEffect(Hollohom.Code,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
function Hollohom.UnequipOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	Duel.RaiseSingleEvent(c,EVENT_CUSTOM+Hollohom.ID,e,r,rp,tp,0)
end

