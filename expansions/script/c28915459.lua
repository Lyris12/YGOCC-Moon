--Phantomb Guardian, 
local ref,id=GetID()
function ref.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigPandemoniumType(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(aux.PandActCheck)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	aux.EnablePandemoniumAttribute(c,e1,TYPE_RITUAL+TYPE_EFFECT+TYPE_PANDEMONIUM,nil,nil,1,nil,false)
	--Targetproof
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(ref.tgprfcon)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1000)
	e3:SetCondition(ref.negcon)
	e3:SetTarget(ref.negtg)
	e3:SetOperation(ref.negop)
	c:RegisterEffect(e3)
end

function ref.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and ref.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(ref.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,ref.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return false end
	local tc=Duel.GetFirstTarget()
	local ex=tc:IsType(TYPE_TRAP)
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.Destroy(c,REASON_EFFECT)
		if ex then Duel.Draw(tp,1,REASON_EFFECT) end
	end
end

--Targetproof
function ref.tgprfcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonLocation()~=LOCATION_DECK
end

--Negate
function ref.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_RITUAL) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		and rp~=tp and Duel.IsChainNegatable(ev)
end
function ref.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if e:GetHandler():GetMaterialCount()>=2 then
		e:SetLabel(1)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD),1,0,0)
	end
end
function ref.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and e:GetLabel()==1 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
	end
end
