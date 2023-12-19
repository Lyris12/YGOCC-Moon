--The Endless March Through The Aeons
--La Marcia Senza Fine Attraverso gli Eoni
--Scripted by: XGlitchy30

local s,id,o=GetID()
Duel.LoadScript("glitchylib_helper.lua")
Duel.LoadScript("glitchylib_aeonstride.lua")
function s.initial_effect(c)
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	aux.RaiseAeonstrideEndOfTurnEvent(c)
	--[[When this card is activated: Move the Turn Count forwards by 1 turn, and place 1 Chronus Counter on this card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[Each time the Turn Count moves forwards, except by this card's effect, place 1 Chronus Counter on this card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TURN_COUNT_MOVED)
	e2:SetRange(LOCATION_FZONE)
	e2:SetFunctions(s.ctcon,nil,nil,s.ctop)
	c:RegisterEffect(e2)
	--[[Once per turn: You can remove 2 Chronus Counters from your field; move the Turn Count forwards or backwards by 1 turn,
	then Special Summon 1 "Aeonstride" monster from your Deck with the same Level as the current Turn Count.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:OPT()
	e3:SetFunctions(nil,aux.RemoveCounterCost(COUNTER_CHRONUS,2),s.sptg,s.spop)
	c:RegisterEffect(e3)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT) and c:IsCanAddCounter(COUNTER_CHRONUS,1,false,LOCATION_FZONE) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,1,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsCanAddCounter(COUNTER_CHRONUS,1,false) and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT) and Duel.MoveTurnCountCustom(1,e,tp,REASON_EFFECT)~=0 then
		c:AddCounter(COUNTER_CHRONUS,1)
	end
end

--E2
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return (aux.TurnCountMovedDueToTurnEnd or ev>0) and (not re or r&REASON_EFFECT==0 or re:GetHandler()~=e:GetHandler())
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsCanAddCounter(COUNTER_CHRONUS,1,false) then
		c:AddCounter(COUNTER_CHRONUS,1)
	end
end

--F3
function s.spfilter(c,e,tp,lv)
	return c:IsSetCard(ARCHE_AEONSTRIDE) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--E3
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetMZoneCount(tp)<=0 then return false end
		local turnct=Duel.GetTurnCount(nil,true)
		for i=-1,1,2 do
			if Duel.IsPlayerCanMoveTurnCount(i,e,tp,REASON_EFFECT) and Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,turnct+i) then
				return true
			end
		end
		return false
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local nums={}
	local turnct=Duel.GetTurnCount(nil,true)
	local spchk=Duel.GetMZoneCount(tp)>0
	local ok=true
	while ok do
		for i=-1,1,2 do
			if Duel.IsPlayerCanMoveTurnCount(i,e,tp,REASON_EFFECT) and (not spchk or Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,turnct+i)) then
				table.insert(nums,i)
			end
		end
		if #nums>0 then
			ok=false
		else
			if spchk then
				spchk=false
			else
				return
			end
		end
	end
	Duel.HintMessage(tp,STRING_INPUT_MOVE_TURN_COUNT)
	local ct1=Duel.AnnounceNumber(tp,table.unpack(nums))
	if Duel.MoveTurnCountCustom(ct1,e,tp,REASON_EFFECT)~=0 and Duel.GetMZoneCount(tp)>0 then
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,Duel.GetTurnCount(nil,true))
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end