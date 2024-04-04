--[[
Voidictator Rune - Chains of Torment
Runa dei Vuotodespoti - Catene del Tormento
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[When a monster(s) is Ritual Summoned, or Summoned from the Extra Deck, to your opponent's field while you control a "Voidictator" monster:
	Equip this card to 1 of those monsters. The equipped monster cannot attack, be Tributed, or used as a material for the Summon of a monster from the Extra Deck, also its ATK/DEF become 0.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(s.condition,s.cost,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is banished because of a "Voidictator" card you own: You can send the top 5 cards of your Deck to the GY, and if you do, place this card on the top of the Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DECKDES|CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:HOPT()
	e2:SetFunctions(s.setcon,nil,s.settg,s.setop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end

--E1
function s.cfilter(c,tp)
	return (c:IsRitualSummoned() or c:IsSpecialSummoned(LOCATION_EXTRA)) and c:IsControler(tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp) and Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_VOIDICTATOR),tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(s.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e2,tp)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.cfilter,nil,1-tp)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) and #g>0 end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) or not c:IsRelateToChain() or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	local g=Duel.GetTargetCards()
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local tg=g:FilterSelect(tp,Card.IsFaceup,1,1,nil)
		local tc=tg:GetFirst()
		if tc then
			Duel.HintSelection(tg)
			if Duel.EquipToOtherCardAndRegisterLimit(e,tp,c,tc) then
				aux.CannotBeEDMaterial(c,nil,"Equip",false,RESET_EVENT|RESETS_STANDARD,c)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_EQUIP)
				e1:SetCode(EFFECT_CANNOT_ATTACK)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				c:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetCode(EFFECT_UNRELEASABLE_SUM)
				e2:SetValue(1)
				e2:SetReset(RESET_EVENT|RESETS_STANDARD)
				c:RegisterEffect(e2)
				local e3=e2:Clone()
				e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
				c:RegisterEffect(e3)
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_EQUIP)
				e4:SetCode(EFFECT_SET_ATTACK)
				e4:SetValue(0)
				e4:SetReset(RESET_EVENT|RESETS_STANDARD)
				c:RegisterEffect(e4)
				local e5=e4:Clone()
				e5:SetCode(EFFECT_SET_DEFENSE)
				c:RegisterEffect(e5)
			else
				c:CancelToGrave(false)
			end
		else
			c:CancelToGrave(false)
		end
	end
end

--E2
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) and c:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,5)
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardDeck(tp,5,REASON_EFFECT)==5 and Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==5 then
		local c=e:GetHandler()
		if c:IsRelateToChain() then
			Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end