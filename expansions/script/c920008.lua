--[[
Curseflame Whirlwind
Turbine Fiammaledetta
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--Tribute 1 "Curseflame" monster you control; distribute a number of Curseflame Counters among face-up cards on the field, equal to the original Level/Rank/Link Rating of the Tributed monster, then, if you Tributed a "Curseflame" monster that began the Duel in the Extra Deck, banish 1 card your opponent controls for every 3 Curseflame Counters on the field, face-down.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:HOPT(true)
	e1:SetFunctions(
		nil,
		aux.DummyCost,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--During your Main Phase, if this card is in your GY, except the turn it was sent there: You can remove 3 Curseflame Counters from anywhere on the field; banish this card, and if you do, Special Summon 1 "Curseflame" monster from your Deck.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_REMOVE|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetRelevantTimings()
	e2:SetFunctions(
		aux.AND(aux.exccon,aux.MainPhaseCond(0)),
		aux.RemoveCounterCost(COUNTER_CURSEFLAME,3,1,1),
		s.rmtg,
		s.rmop
	)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c,tp)
	local lv,type=c:GetOriginalRatingAuto()
	if not (lv>0 and (type==0 or type&TYPE_XYZ|TYPE_LINK>0)) or not c:IsSetCard(ARCHE_CURSEFLAME) then return false end
	if c:IsSetCard(ARCHE_CURSEFLAME) and c:IsOriginalType(TYPE_EXTRA) then
		local ct=Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)+lv-c:GetCounter(COUNTER_CURSEFLAME)
		if ct<3 or not Duel.IsExists(false,Card.IsAbleToRemoveFacedown,tp,0,LOCATION_ONFIELD,math.floor(ct/3),c,tp) then
			return false
		end
	end
	local g=Duel.Group(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	return g:CheckSubGroup(aux.DistributeCountersGroupCheck(COUNTER_CURSEFLAME),1,#g,lv)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() and Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp)
	end
	local sc=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp):GetFirst()
	if sc then
		local lv=sc:GetOriginalRatingAuto()
		local check=sc:IsSetCard(ARCHE_CURSEFLAME) and sc:IsOriginalType(TYPE_EXTRA)
		Duel.Release(sc,REASON_COST)
		Duel.SetTargetParam(lv)
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,lv,tp,COUNTER_CURSEFLAME)
		if check then
			e:SetCategory(CATEGORY_COUNTER|CATEGORY_REMOVE)
			e:SetLabel(1)
			local g=Duel.Group(Card.IsAbleToRemoveFacedown,tp,0,LOCATION_ONFIELD,nil,tp)
			local ct=Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)+lv
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,math.floor(ct/3),0,0)
		else
			e:SetCategory(CATEGORY_COUNTER)
			e:SetLabel(0)
		end
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.GetTargetParam()
	if not lv or lv==0 then return end
	local g=Duel.Group(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ActivateException(e,false))
	if #g>0 and Duel.DistributeCounters(tp,COUNTER_CURSEFLAME,lv,g,id)>0 and e:GetLabel()==1 then
		local ct=Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)
		local val=math.floor(ct/3)
		if val<1 then return end
		local rg=Duel.Select(HINTMSG_REMOVE,false,tp,Card.IsAbleToRemoveFacedown,tp,0,LOCATION_ONFIELD,val,val,tp)
		if #rg>0 then
			Duel.HintSelection(rg)
			Duel.BreakEffect()
			Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end

--E2
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_CURSEFLAME) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemove() and Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_REMOVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 and Duel.GetMZoneCount(tp)>0 then
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end