--Aurogeois, Deptheaven's Decree
local ref,id=GetID()
Duel.LoadScript("Deptheaven.lua")
Duel.LoadScript("GLShortcuts.lua")
function ref.initial_effect(c)
	c:SetUniqueOnField(LOCATION_MZONE,0,id)
	aux.AddXyzProcedure(c,nil,5,2,nil,nil,99)
	c:EnableReviveLimit()
	Deptheaven.AddXyzRevive(c,ref.revivecon,aux.TRUE)
	--ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCost(ref.atkcost)
	e1:SetTarget(ref.atktg)
	e1:SetOperation(ref.atkop)
	c:RegisterEffect(e1)
end

--Revive
function ref.revivecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,e:GetHandler(),TYPE_PENDULUM)
end

function ref.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
	local g=Duel.GetOperatedGroup()
	Debug.Message(#g)
	if g:IsExists(Deptheaven.Is,1,nil) then e:SetLabel(1) else e:SetLabel(0) end
	--[[local tc=g:GetFirst()
	while tc do Debug.Message(tc:GetCode()) tc=g:GetNext() end
	Debug.Message(g:IsExists(Deptheaven.Is,1,nil))
	Debug.Message(e:GetLabel())]]
end
function ref.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,g:GetFirst():GetAttack()/2)
	if e:GetLabel()==1 then Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0) end
end
function ref.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Glitchy.SingleEffectGiver(e:GetHandler(),tc,EFFECT_SET_ATTACK_FINAL,RESET_EVENT+RESETS_STANDARD,tc:GetAttack()/2)
		if e:GetLabel() then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			Glitchy.SingleEffectGiver(e:GetHandler(),tc,EFFECT_DISABLE,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			Glitchy.SingleEffectGiver(e:GetHandler(),tc,EFFECT_DISABLE_EFFECT,RESET_TURN_SET+RESET_PHASE+PHASE_END)
			Duel.AdjustInstantly(tc)
		end
		--Glitchy.SingleEffectGiver(e:GetHandler(),tc,EFFECT_SET_DEFENSE_FINAL,RESETS_STANDARD,tc:GetDefense()/2)
	end
end

