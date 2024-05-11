--[[
Number i210: Fallen of Verdanse
Numero i210: Caduto di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),5,2,s.mfilter,aux.Stringid(id,2),2,s.altop)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCondition(s.lscon)
	e0:SetOperation(s.lsop)
	c:RegisterEffect(e0)
	--[[If this card is Xyz Summoned: You can make your opponent reveal 1 random face-down card in their Extra Deck;
	for the rest of this turn and for the next 3 turns after this effect resolves, each time your opponent Special Summons a monster(s) with that same name,
	they immediately take 1200 damage.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[(Quick Effect): You can detach 1 material from a DARK Xyz Monster you control; shuffle 1 card on the field into the Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		nil,
		s.tdcost,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e2)
end
function s.mfilter(c,e,tp,xyzc)
	return c:IsFaceup() and c:IsXyzType(TYPE_MONSTER) and c:IsXyzType(TYPE_RITUAL) and c:IsSetCard(ARCHE_VERDANSE) and c:IsXyzLevel(xyzc,10) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.altop(e,tp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_TOFIELD|RESET_PHASE|PHASE_END,0,1)
end

--E0
function s.lscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.lsop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(1-tp,3):Filter(Card.IsCanOverlay,nil,tp)
	if #g>0 then
		local c=e:GetHandler()
		Duel.Hint(HINT_CARD,0,id)
		Duel.DisableShuffleCheck()
		Duel.Attach(g,c)
	end
end

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsFacedown,tp,0,LOCATION_EXTRA,nil)
	if chk==0 then return #g>0 end
	local rg=g:RandomSelect(1-tp,1)
	Duel.ConfirmCards(tp,rg)
	Duel.ConfirmCards(1-tp,rg)
	local tc=rg:GetFirst()
	e:SetLabel(tc:GetCode())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local codes={e:GetLabel()}
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetLabel(table.unpack(codes))
	e4:SetCondition(s.drcon1)
	e4:SetOperation(s.drop1)
	e4:SetReset(RESET_PHASE|PHASE_END,4)
	Duel.RegisterEffect(e4,tp)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_SZONE)
	e5:SetLabel(table.unpack(codes))
	e5:SetCondition(s.regcon)
	e5:SetOperation(s.regop)
	e5:SetReset(RESET_PHASE|PHASE_END,4)
	Duel.RegisterEffect(e5,tp)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e6:SetCode(EVENT_CHAIN_SOLVED)
	e6:SetRange(LOCATION_SZONE)
	e6:SetLabel(table.unpack(codes))
	e6:SetCondition(s.drcon2)
	e6:SetOperation(s.drop2)
	e6:SetReset(RESET_PHASE|PHASE_END,4)
	Duel.RegisterEffect(e6,tp)
end
function s.chkfilter(c,tp,...)
	return c:IsFaceup() and c:IsSummonPlayer(1-tp) and c:IsCode(...)
end
function s.drcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.chkfilter,1,nil,tp,e:GetLabel())
		and not Duel.IsChainSolving()
end
function s.drop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Damage(1-tp,1200,REASON_EFFECT)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.chkfilter,1,nil,tp,e:GetLabel())
		and Duel.IsChainSolving()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end
function s.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.drop2(e,tp,eg,ep,ev,re,r,rp)
	local n=Duel.GetFlagEffect(tp,id)
	Duel.ResetFlagEffect(tp,id)
	for i=1,n do
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Damage(1-tp,1200,REASON_EFFECT)
	end
end

--E2
function s.cfilter2(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and c:GetOverlayCount()>0 and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE,0,1,1,nil,tp)
	if #g>0 then
		g:GetFirst():RemoveOverlayCard(tp,1,1,REASON_COST)
	end
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end