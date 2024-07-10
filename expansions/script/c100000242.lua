--[[
Automatyrant Subspace Dragon
Automatiranno Drago Subspaziale
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If you control a Level 5 or 7 "Automatyrant" monster: You can send the top 3 cards of your Deck to the GY;
	Special Summon this card from your hand, and if you do, you can make the Levels of all Level 5 or higher "Automatyrant" monsters you currently control become 8 until the end of this turn.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(s.spcon,s.spcost,s.sptg,s.spop)
	c:RegisterEffect(e1)
	--[[If this card is detached from an Xyz Monster to activate that monster's effect: You can take 1 Level 7 or higher "Automatyrant" monster, except "Automatyrant Subspace Dragon",
	and either Special Summon it, or attach it to a Machine Xyz Monster you control as material, then if you activated this effect during the Battle Phase,
	double the ATK of all "Automatyrant" monsters you currently control with 2500 or more original ATK, until the end of this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_MOVE)
	e2:HOPT()
	e2:SetFunctions(s.condition,nil,s.target,s.operation)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevel(5,7) and c:IsSetCard(ARCHE_AUTOMATYRANT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) end
	Duel.DiscardDeck(tp,3,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and not c:IsLevel(8) and c:IsSetCard(ARCHE_AUTOMATYRANT)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Group(s.lvfilter,tp,LOCATION_MZONE,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,STRING_ASK_CHANGE_LEVEL) then
			for tc in aux.Next(g) do
				tc:ChangeLevel(8,RESET_PHASE|PHASE_END,{c,true})
			end
		end
	end
end

--E2
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_DECK|LOCATION_HAND) or c:IsBanished(POS_FACEDOWN) or not c:IsReason(REASON_COST) or not c:IsPreviousLocation(LOCATION_OVERLAY)
		or not re:IsActivated() or not re:IsActiveType(TYPE_MONSTER) then
		return false
	end
	local rc=re:GetHandler()
	local ch=Duel.GetCurrentChain()
	local race=rc:IsRelateToChain(ch) and rc:GetRace() or Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_RACE)
	return rc and rc==c:GetPreviousXyzHolder() and race&RACE_MACHINE>0
end
function s.gepdfilter(c,e,tp,ft)
	return c:IsLevelAbove(7) and c:IsSetCard(ARCHE_AUTOMATYRANT) and not c:IsCode(id)
		and ((ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) or (c:IsCanOverlay(tp) and Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_MZONE,0,1,nil,e)))
end
function s.attfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE) and not c:IsImmuneToEffect(e)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_AUTOMATYRANT) and c:GetBaseAttack()>=2500
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gepdfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
	local param=0
	if Duel.IsBattlePhase() then
		param=1
		e:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_ATKCHANGE)
		local g=Duel.Group(s.atkfilter,tp,LOCATION_MZONE,0,nil)
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,LOCATION_MZONE,0,OPINFO_FLAG_DOUBLE)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	end
	Duel.SetTargetParam(param)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local tc=Duel.SelectMatchingCard(tp,s.gepdfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft):GetFirst()
	if not tc then return end
	local b1=ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local b2=Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_MZONE,0,1,nil,e)
	if not b1 and not b2 then return end
	local opt=aux.Option(tp,nil,nil,{b1,STRING_SPECIAL_SUMMON},{b2,STRING_ATTACH})
	local success_chk=false
	if opt==0 and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		success_chk=true
	elseif opt==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local oc=Duel.SelectMatchingCard(tp,s.attfilter,tp,LOCATION_MZONE,0,1,1,nil,e):GetFirst()
		if oc then
			Duel.HintSelection(Group.FromCards(oc))
			if Duel.Attach(tc,oc) then
				success_chk=true
			end
		end
	end
	local ng=Duel.Group(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	if success_chk and Duel.GetTargetParam()==1 and #ng>0 and e:IsActivated() then
		local c=e:GetHandler()
		Duel.BreakEffect()
		for sc in aux.Next(ng) do
			sc:DoubleATK(RESET_PHASE|PHASE_END,{c,true})
		end
	end
end