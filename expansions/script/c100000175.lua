--[[
Grand Twist Dragon
Drago Svolta Grandiosa
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	--[[During your Main Phase: You can equip 1 Equip Spell from either GY to this card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:HOPT()
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	--[[When a card or effect is activated that targets a card(s) on the field (Quick Effect):
	You can send this card to the GY; negate the activation, then, if this card was equipped with "Tome of Twisted Tales" when this effect was activated,
	you can shuffle 1 card on the field into the Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetLabel(0)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
--E1
function s.eqfilter(c,ec,tp)
	return c:IsSpell(TYPE_EQUIP) and c:CheckEquipTarget(ec) and (c:IsControler(tp) or c:IsAbleToChangeControler()) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e:GetHandler(),tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,PLAYER_ALL,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,PLAYER_ALL,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToChain() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,c,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.Equip(tp,tc,c)
	end
end

--E2
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(Card.IsOnField,1,nil) and Duel.IsChainNegatable(ev)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(id+1)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	local g=c:GetEquipGroup()
	if g and g:IsExists(s.cfilter,1,nil) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local l=e:GetLabel()
	if l==1 and e:IsActivated() then
		e:SetCategory(CATEGORY_NEGATE|CATEGORY_TODECK)
		local g=Duel.Group(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	else
		e:SetCategory(CATEGORY_NEGATE)
	end
	Duel.SetTargetParam(l)
	e:SetLabel(0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and e:IsActivated() then
		local l=Duel.GetTargetParam()
		if l and l==1 then
			local g=Duel.Group(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
			if #g>0 and Duel.SelectYesNo(tp,STRING_ASK_TO_DECK) then
				Duel.HintMessage(tp,HINTMSG_TODECK)
				local sg=g:Select(tp,1,1,nil)
				if #sg>0 then
					Duel.HintSelection(sg)
					Duel.BreakEffect()
					Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
				end
			end
		end
	end
end