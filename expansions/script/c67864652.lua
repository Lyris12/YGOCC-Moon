--VECTOR Frame Omnis
--Scripted by Keddy, updated by Zerry
function c67864652.initial_effect(c)
	c:SetUniqueOnField(1,0,67864652)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,c67864652.ffilter,c67864652.ffilter2,false)
	--Equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67864652,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c67864652.condition)
	e1:SetTarget(c67864652.target)
	e1:SetOperation(c67864652.operation)
	c:RegisterEffect(e1)
	--ATK Gain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e2:SetValue(c67864652.value)
	c:RegisterEffect(e2)
end
function c67864652.ffilter(c)
	return c:IsSetCard(0x2a6) and c:IsRace(RACE_CYBERSE)
end
function c67864652.ffilter2(c)
	return c:IsRace(RACE_MACHINE)
end
function c67864652.eqfilter(c,e,tp,ec)
	return c:IsSetCard(0x2a6)
end
function c67864652.vfilter(c)
	return c:IsSetCard(0x2a6) and c:IsFaceup()
end
--Equip
function c67864652.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c67864652.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c67864652.eqfilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>(e:GetHandler():IsLocation(LOCATION_SZONE) and 0 or 1)
		and Duel.IsExistingTarget(c67864652.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,c67864652.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c67864652.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
	if aux.CheckUnionEquip(tc,e:GetHandler()) and Duel.Equip(tp,tc,e:GetHandler()) then
   	 	aux.SetUnionState(tc)
		end
	end
end
--Atk Gain
function c67864652.value(e,c)
	return Duel.GetMatchingGroupCount(c67864652.vfilter,c:GetControler(),LOCATION_SZONE,0,nil)*500
end