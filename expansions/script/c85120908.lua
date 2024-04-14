--[[
Primordial Singularity
Singolarità Primordiale
Card Author: LeonDuvall
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MACRO_COSMOS,CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_HELIOS_DUO_MEGISTUS,CARD_HELIOS_TRICE_MEGISTUS)
	--[[Shuffle 1 each of your banished "Helios - The Primordial Sun", "Helios Duo Megistus", and "Helios Trice Megistus" into the Deck; shuffle all banished cards into the Deck(s), also destroy all cards on the field, except "Macro Cosmos".]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(nil,s.cost,s.target,s.operation)
	c:RegisterEffect(e1)
	--[[If this card is currently banished, except the turn it was banished: You can shuffle this card into the Deck;
	Set 1 Spell/Trap that mentions "Helios - The Primordial Sun" directly from your Deck, then, if you control "Macro Cosmos", it can be activated this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_REMOVED)
	e2:HOPT()
	e2:SetFunctions(s.setcon,aux.ToDeckSelfCost,s.settg,s.setop)
	c:RegisterEffect(e2)
end
s.hnchecks=aux.CreateChecks(Card.IsCode,{CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_HELIOS_DUO_MEGISTUS,CARD_HELIOS_TRICE_MEGISTUS})

--E1
function s.hngoal(g,og,fchk)
	return fchk or og:IsExists(aux.TRUE,1,g)
end
function s.filter(c)
	return c:IsFacedown() or not c:IsCode(CARD_MACRO_COSMOS)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetBanishment():Filter(Card.IsAbleToDeck,nil)
	local cg=g:Filter(aux.Faceup(Card.IsAbleToDeckAsCost),nil)
	local fg=Duel.Group(s.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ActivateException(e,chk==0))
	local fchk=#fg>0
	if chk==0 then
		return cg:CheckSubGroupEach(s.hnchecks,s.hngoal,g,fchk)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=cg:SelectSubGroupEach(tp,s.hnchecks,false,s.hngoal,g,fchk)
	if #sg>0 then
		Duel.HintSelection(sg)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetBanishment():Filter(Card.IsAbleToDeck,nil)
	local fg=Duel.Group(s.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ActivateException(e,chk==0))
	if chk==0 then
		return e:IsCostChecked() or #g>0 or #fg>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,PLAYER_ALL,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,fg,#fg,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetBanishment():Filter(Card.IsAbleToDeck,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	local fg=Duel.Group(s.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ActivateException(e,false))
	if #fg>0 then
		Duel.Destroy(fg,REASON_EFFECT)
	end
end

--E2
function s.setcon(e)
	return Duel.GetTurnCount()~=e:GetHandler():GetTurnID()
end
function s.setfilter(c,costchk)
	return c:IsST() and c:Mentions(CARD_HELIOS_THE_PRIMORDIAL_SUN) and c:IsSSetable() and (costchk or c:IsOriginalType(TYPE_ST))
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return (e:IsCostChecked() and s.setfilter(e:GetHandler(),true)) or Duel.IsExists(false,s.setfilter,tp,LOCATION_DECK,0,1,nil)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSetAndFastActivation(tp,g,e,s.qecon,true)
	end
end
function s.qecon(e,tp)
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_MACRO_COSMOS),tp,LOCATION_ONFIELD,0,1,nil)
end