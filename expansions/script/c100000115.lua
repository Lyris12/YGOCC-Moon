--Corpse King of Eternal Reincarnation
--Re Cadaverico della Reincarnazione Eterna
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),4,2)
	--[[During your Main Phase: You can detach 1 material from this card; take 1 Zombie monster from your Deck, and either add it to your hand or send it to your GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_TOGRAVE|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetFunctions(aux.MainPhaseCond(0),aux.DetachSelfCost(),s.target,s.operation)
	c:RegisterEffect(e1)
	--[[If this card is destroyed by battle or card effect: You can target 2 Zombie monsters with the same Level in your GY;
	Special Summon them, then, immediately after this effect resolves, Xyz Summon 1 Xyz Monster, except "Corpse King of Eternal Reincarnation", using those 2 monsters only.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:HOPT()
	e2:SetFunctions(aux.ByBattleOrCardEffect(),nil,s.sptg,s.spop)
	c:RegisterEffect(e2)
end
--FE1
function s.cfilter(c)
	return c:IsMonster() and c:IsRace(RACE_ZOMBIE) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,STRING_ADD_TO_HAND,STRING_SEND_TO_GY)==0) then
			Duel.Search(tc,tp)
		else
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end

--FE2
function s.filter(c,e,tp)
	return c:IsMonster() and c:IsRace(RACE_ZOMBIE) and c:HasLevel() and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gcheck(g)
	return g:GetClassCount(Card.GetLevel)==1 and Duel.IsExists(false,s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g)
end
function s.xyzfilter(c,mg)
	return not c:IsCode(id) and c:IsXyzSummonable(mg,2,2)
end
--E2
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then
		return #mg>1 and mg:CheckSubGroup(s.gcheck,2,2)
			and Duel.IsPlayerCanSpecialSummonCount(tp,2) and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=mg:SelectSubGroup(tp,s.gcheck,false,2,2)
	Duel.SetTargetCard(g)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
	Duel.SetAdditionalOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetTargetCards():Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
	if #g<2 then return end
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==2 then
		local og=Duel.GetOperatedGroup()
		local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,og)
		if #xyzg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
			if xyz then
				Duel.BreakEffect()
				Duel.XyzSummon(tp,xyz,og)
			end
		end
	end
end