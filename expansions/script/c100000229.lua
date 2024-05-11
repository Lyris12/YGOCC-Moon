--[[
Dominion of Verdanse
Dominio di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,2,2,s.lcheck)
	--You can also use 1 monster from your hand as material to Link Summon this card.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_HAND,0)
	e0:SetValue(s.matval)
	c:RegisterEffect(e0)
	--[[If this card is Special Summoned: You can pay 3000 LP; shuffle all banished cards and all cards in the GYs into the Decks, and if you do,
	if 15 or more cards were shuffled into the Deck with this effect, negate the effects of all face-up cards your opponent currently controls.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.LinkSummonedCond,
		aux.PayLPCost(3000),
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e1)
	--[[During the Main Phase (Quick Effect): You can Tribute this card or 1 monster this card points to; Special Summon 1 Level 5 "Verdanse" Ritual Monster from your hand or GY.
	(This is treated as a Ritual Summon.)]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCustomCategory(CATEGORY_SPSUMMON_RITUAL_MONSTER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		aux.MainPhaseCond(),
		s.spcost,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e2)
end
function s.matfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_DARK) and c:IsLinkRace(RACE_FAIRY)
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_RITUAL)
end

--E0
function s.exmatcheck(c,lc,tp)
	if not c:IsLocation(LOCATION_HAND) then return false end
	local le={c:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
	for _,te in pairs(le) do	 
		local f=te:GetValue()
		local related,valid=f(te,lc,nil,c,tp)
		if related and not te:GetHandler():IsCode(id) then return false end
	end
	return true	 
end
function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	return true, not mg or not mg:IsExists(s.exmatcheck,1,nil,lc,tp)
end

--E1
function s.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetBanishment():Filter(Card.IsAbleToDeck,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetBanishment():Filter(Card.IsAbleToDeck,nil)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 and Duel.GetGroupOperatedByThisEffect(e):GetCount()>=15 then
		local ng=Duel.Group(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
		if #ng>0 then
			Duel.Negate(ng,e,0,false,false,TYPE_NEGATE_ALL)
		end
	end
end

--E2
function s.cfilter(c,g,tp)
	return g:IsContains(c) and Duel.GetMZoneCount(tp,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	lg:AddCard(c)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,lg,tp) end
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,lg,tp)
	Duel.Release(g,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsMonster(TYPE_RITUAL) and c:IsSetCard(ARCHE_VERDANSE) and c:IsLevel(5) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetPossibleCustomOperationInfo(0,CATEGORY_SPSUMMON_RITUAL_MONSTER,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		tc:SetMaterial(nil)
		if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end