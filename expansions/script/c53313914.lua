--Mysterious Cryophoenix
function c53313914.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--Once per turn: You can target 1 "Mysterious" monster you control, it can attack your opponent directly, but it is destroyed during the end phase.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(aux.PandActCheck)
	e2:SetTarget(c53313914.attg)
	e2:SetOperation(c53313914.atop)
	c:RegisterEffect(e2)
	aux.EnablePandemoniumAttribute(c,e2)
	--Cannot be Normal Summoned/Set.
	c:EnableReviveLimit()
	--Must be Special Summoned (from your hand) by Tributing 1 Level 4 or lower "Mysterious" monster you control.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetDescription(2)
	e1:SetCondition(c53313914.spcon)
	e1:SetOperation(c53313914.spop)
	c:RegisterEffect(e1)
	--M: Once per turn: You can banish 1 other "Mysterious" monster you control and target 1 card your opponent controls; banish that target.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetCost(c53313914.rmcost)
	e3:SetTarget(c53313914.rmtg)
	e3:SetOperation(c53313914.rmop)
	c:RegisterEffect(e3)
end
function c53313914.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xcf6) and c:IsAttackable() and not c:IsHasEffect(EFFECT_DIRECT_ATTACK)
end
function c53313914.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53313914.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c53313914.filter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsAbleToEnterBP() and e:GetHandler():GetFlagEffect(53313914)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c53313914.filter,tp,LOCATION_MZONE,0,1,1,nil)
	e:GetHandler():RegisterFlagEffect(53313914,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,1)
end
function c53313914.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(53313914,RESET_EVENT+0x1fe0000,0,1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCountLimit(1)
		e2:SetLabelObject(tc)
		e2:SetCondition(c53313914.tgcon)
		e2:SetOperation(c53313914.tgop)
		Duel.RegisterEffect(e2,tp)
	end
end
function c53313914.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(53313914)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
function c53313914.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Destroy(tc,REASON_EFFECT)
end
function c53313914.spfilter(c,tp,ft)
	return c:IsSetCard(0xcf6) and c:IsLevelBelow(4)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
function c53313914.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return ft>-1 and Duel.CheckReleaseGroup(tp,c53313914.spfilter,1,nil,tp,ft)
end
function c53313914.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.SelectReleaseGroup(tp,c53313914.spfilter,1,1,nil,tp,ft)
	Duel.Release(g,REASON_COST)
end
function c53313914.thcfilter(c,tp)
	return c:IsSetCard(0xcf6) and c:IsAbleToRemoveAsCost()
end
function c53313914.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313914.thcfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c53313914.thcfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c53313914.rmfilter(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function c53313914.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(c53313914.rmfilter,tp,0,LOCATION_ONFIELD,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,c53313914.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c53313914.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFirstTarget()
	if g:IsRelateToEffect(e) and g:IsControler(1-tp) and not g:IsImmuneToEffect(e) then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
