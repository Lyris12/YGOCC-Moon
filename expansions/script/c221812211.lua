--[[
BRAIN Boot Sector
Settore di Avvio CERVELLO
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--[[During your Draw Phase, before you draw: You can give up your normal draw this turn, and if you do, add 1 Level 1 "Viravolve" monster from your Deck to your hand,
	and if you do that, you can shuffle 1 Level 1 "Viravolve" monster from your GY into the Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--[[Once per turn, if a "Viravolve" monster(s) you control is destroyed by battle or card effect: You can Special Summon from your hand or Deck, 1 monster with the same name as 1 of those monsters.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_DESTROYED,s.cfilter,id,LOCATION_FZONE,nil,LOCATION_FZONE,s.RegisterTableAddress,nil,nil,s.RegisterNameInTable)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_FZONE)
	e2:OPT()
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	if not s.MergedDelayedEventInfotable then
		s.MergedDelayedEventInfotable={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TURN_END)
		ge1:OPT()
		ge1:SetOperation(s.resetop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.resetop()
	s.MergedDelayedEventInfotable={}
end

--E1
function s.thfilter(c,f)
	return c:IsSetCard(ARCHE_VIRAVOLVE) and c:IsType(TYPE_MONSTER) and c:IsLevel(1) and f(c)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and Duel.GetDrawCount(tp)>0
end
--
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,Card.IsAbleToHand) end
	local dt=Duel.GetDrawCount(tp)
	if dt~=0 then
		aux.DrawReplaceCount=0
		aux.DrawReplaceMax=dt
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE|PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	aux.DrawReplaceCount=aux.DrawReplaceCount+1
	if aux.DrawReplaceCount>aux.DrawReplaceMax then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,Card.IsAbleToHand)
	if #g>0 and Duel.SearchAndCheck(g,tp) then
		local tg=Duel.Group(aux.Necro(s.thfilter),tp,LOCATION_GRAVE,0,nil,Card.IsAbleToDeck)
		if #tg>0 and Duel.SelectYesNo(tp,STRING_ASK_TO_DECK) then
			Duel.HintMessage(tp,HINTMSG_TODECK)
			local sg=tg:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end

--E2
function s.RegisterNameInTable(c)
	if not s.MergedDelayedEventInfotable[MERGED_ID] then
		s.MergedDelayedEventInfotable[MERGED_ID] = {}
	end
	local codes={c:GetPreviousCodeOnField()}
	for _,code in ipairs(codes) do
		table.insert(s.MergedDelayedEventInfotable[MERGED_ID],code)
	end
end
function s.RegisterTableAddress()
	return MERGED_ID
end
function s.cfilter(c,_,tp)
	return c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(ARCHE_VIRAVOLVE)
end
function s.filter(c,e,tp,ev)
	local codes={c:GetCode()}
	return c:IsSetCard(ARCHE_VIRAVOLVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and aux.FindInTable(s.MergedDelayedEventInfotable[ev],nil,table.unpack(codes))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp,ev)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp,ev)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end