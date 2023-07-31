--Hinotama Rage
--Rabbia Hinotama
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[① When a non-FIRE monster effect is activated, while you control no Special Summoned monsters (Quick Effect):
	You can discard this card; negate that effect, and if you do, send 1 "Hinotama" from your hand or Deck to the GY, also inflict 600 damage to your opponent.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DISABLE|CATEGORY_TOGRAVE|CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(s.discon,aux.DiscardSelfCost,s.distg,s.disop)
	c:RegisterEffect(e1)
	--[[You can banish this card from your GY, then target 1 FIRE monster on the field; it gains 600 ATK, until the end of your opponent's next  turn.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(nil,aux.bfgcost,s.atktg,s.atkop)
	c:RegisterEffect(e2)
end
--E1
function s.tgfilter(c)
	return c:IsCode(46130346) and c:IsAbleToGrave()
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsDisabled() or not Duel.IsChainDisablable(ev) then return false end
	local attr=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_ATTRIBUTE)
	return re:IsActiveType(TYPE_MONSTER) and attr&(ATTRIBUTE_ALL&(~ATTRIBUTE_FIRE))>0
		and not Duel.IsExists(false,Card.IsSummonType,tp,LOCATION_MZONE,0,1,nil,SUMMON_TYPE_SPECIAL)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_DISABLED) and Duel.IsExists(false,s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
	Duel.Damage(1-tp,600,REASON_EFFECT)
end

--E2
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,g:GetFirst():GetControler(),LOCATION_MZONE,600)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsFaceup() then
		local rct=Duel.GetNextPhaseCount(PHASE_END,1-tp)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_OPPO_TURN,rct)
		e1:SetValue(600)
		tc:RegisterEffect(e1)
	end
end