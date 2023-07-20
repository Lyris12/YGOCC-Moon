--Dixy Nix, Flibberty Cartoonist
--Dixy Nix, Cartonista Rivelibbertà
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+1
	end
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	--[[While you control a Set monster, this card cannot be targeted for attacks, but does not prevent your opponent from attacking you directly.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e1:SetCondition(s.condition)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--[[If this card is Link Summoned: You can discard 1 card; Set 1 "Flibberty" card directly from your Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(aux.LinkSummonedCond,aux.DiscardCost(),s.settg,s.setop)
	c:RegisterEffect(e2)
	--[[If a monster(s) is Set to a zone this card points to (except during the Damage Step): You can flip that monster(s) face-up.]]
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,{EVENT_CHANGE_POS,EVENT_MSET,EVENT_SPSUMMON_SUCCESS},s.cfilter,id,LOCATION_MZONE,nil,nil,nil,id+100)
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CUSTOM+s.progressive_id)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(nil,nil,s.postg,s.posop)
	c:RegisterEffect(e3)
end
function s.matfilter(c)
	return c:IsLinkType(TYPE_FLIP) and c:IsAttackBelow(1000)
end

--E1 
function s.condition(e)
	return Duel.IsExists(false,Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--FE2
function s.setfilter(c,e,tp)
	if not c:IsSetCard(ARCHE_FLIBBERTY) then return false end
	if c:IsMonster() then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	elseif c:IsST() then
		return c:IsSSetable()
	end
	return false
end
--E2
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.setfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_OPERATECARD,false,tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	if tc:IsMonster() then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
			Duel.ConfirmCards(1-tp,g)
		end
	elseif tc:IsST() then
		Duel.SSet(tp,tc)
	end
end

--FE3
function s.cfilter(c,e,_,eg,_,_,_,_,_,_,event)
	local h=e:GetHandler()
	if not h:IsType(TYPE_LINK) or eg:IsContains(h) then return false end
	return c:IsFacedown() and h:GetLinkedGroup():IsContains(c) and (event~=EVENT_CHANGE_POS or c:IsPreviousPosition(POS_FACEUP))
end
function s.posfilter(c)
	if c:IsFaceup() or c:IsPosition(POS_FACEDOWN_ATTACK) then
		return c:IsCanTurnSetGlitchy()
	else
		return c:IsCanChangePosition()
	end
end
--E3
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.posfilter,nil)
	if chk==0 then
		return #g>0
	end
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		g=g:SelectSubGroup(tp,aux.SimultaneousEventGroupCheck,false,1,#g,id+100,g)
	end
	Duel.HintSelection(g)
	Duel.SetTargetCard(g)
	Duel.SetCardOperationInfo(g,CATEGORY_POSITION)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 then
		Duel.Flip(g,POS_FACEUP)
	end
end