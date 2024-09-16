--[[
Eternadir Behemoth Eghyt
Behemoth Eternadir Eghyt
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumMod()
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+1
	end
	c:EnableReviveLimit()
	aux.EnablePendulumAttribute(c,false)
	aux.AddXyzProcedure(c,nil,11,2)
	--[[Once per turn: You can Special Summon 1 "Eternadir" monster from your Deck, ignoring its Summoning conditions.]]
	local p1=Effect.CreateEffect(c)
	p1:Desc(0)
	p1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	p1:SetType(EFFECT_TYPE_IGNITION)
	p1:SetRange(LOCATION_PZONE)
	p1:OPT()
	p1:SetFunctions(nil,nil,s.sptg,s.spop)
	c:RegisterEffect(p1)
	--[[If this card in a Monster Zone is destroyed: You can Tribute 1 card in your Pendulum Zone, and if you do, place this card in your Pendulum Zone.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetFunctions(s.pzcon,nil,s.pztg,s.pzop)
	c:RegisterEffect(e1)
	--[[During your opponent's Main Phase (Quick Effect): You can Tribute this card with material; immediately after this effect resolves, Pendulum Summon an "Eternadir" monster(s).]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(aux.MainPhaseCond(1),s.pscost,s.pstg,s.psop)
	c:RegisterEffect(e2)
	--[[If another "Eternadir" card(s) you control is destroyed or Tributed: You can add 1 "Eternadir" card with a different name than those card(s), from your Deck to your hand.]]
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,{EVENT_DESTROYED,EVENT_RELEASE},s.cfilter,id,LOCATION_MZONE,nil,LOCATION_MZONE,s.RegisterTableAddress,nil,nil,s.RegisterNameInTable)
	local e3=Effect.CreateEffect(c)
	e3:Desc(3)
	e3:SetCategory(CATEGORIES_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_CUSTOM+s.progressive_id)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(nil,nil,s.thtg,s.thop)
	c:RegisterEffect(e3)
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
s.pendulum_level=11

function s.resetop()
	s.MergedDelayedEventInfotable={}
end

--P1
function s.filter(c,e,tp)
	return c:IsSetCard(ARCHE_ETERNADIR) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end

--E1
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE)
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:CheckUniqueOnField(tp,LOCATION_PZONE) and Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,LOCATION_PZONE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_PZONE)
	if c:IsInGY() then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,c:GetControler(),0)
	end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.Select(HINTMSG_RELEASE,false,tp,Card.IsReleasableByEffect,tp,LOCATION_PZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(Group.FromCards(tc))
		if Duel.Release(tc,REASON_EFFECT)~=0 then
			local c=e:GetHandler()
			if c:IsRelateToChain() and c:CheckUniqueOnField(tp,LOCATION_PZONE) and Duel.CheckPendulumZones(tp) then
				Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end
	end
end

--E2
function s.psfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_ETERNADIR) and c:IsMonster()
end
function s.pcheck(e,tp,c)
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	if lpz==nil then
		lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		if lpz==nil then
			return false
		end
	end
	local g=Duel.GetMatchingGroup(s.psfilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,nil)
	if #g==0 then return false end
	aux.LeavingCardForPendulumSummon=e:GetHandler()
	local res=aux.PendCondition(e,lpz,g)
	aux.LeavingCardForPendulumSummon=nil
	return res
end
function s.excostfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsHasEffect(CARD_ETERNADIR_SCOUT_ESOM,tp)
end
function s.pscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local check=c:IsReleasable() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0 and s.pcheck(e,tp,c)
	local g2=Duel.GetMatchingGroup(s.excostfilter,tp,LOCATION_GRAVE,0,nil,tp)
	if chk==0 then
		return check or (#g2>0 and s.pcheck(e,tp,nil))
	end
	local exchk=#g2>0
	if exchk and (not check or Duel.SelectYesNo(tp,aux.Stringid(CARD_ETERNADIR_SCOUT_ESOM,2))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=g2:Select(tp,1,1,nil)
		local tc=rg:GetFirst()
		local te=tc:IsHasEffect(CARD_ETERNADIR_SCOUT_ESOM,tp)
		Duel.Hint(HINT_CARD,0,tc)
		te:UseCountLimit(tp)
		Duel.Remove(tc,POS_FACEUP,REASON_COST|REASON_REPLACE)
	else
		Duel.Release(c,REASON_COST)
	end
end
function s.pstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() or s.pcheck(e,tp,nil)
	end
end
function s.psop(e,tp,eg,ep,ev,re,r,rp)
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	if lpz==nil then
		lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		if lpz==nil then
			return false
		end
	end
	local g=Duel.GetMatchingGroup(s.psfilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,nil)
	if #g==0 then return end
	local sg=Group.CreateGroup()
	aux.LeavingCardForPendulumSummon=e:GetHandler()
	aux.PendOperation(e,tp,eg,ep,ev,re,r,rp,lpz,sg,g)
	aux.LeavingCardForPendulumSummon=nil
	Duel.RaiseEvent(sg,EVENT_SPSUMMON_SUCCESS_G_P,e,REASON_EFFECT,tp,tp,0)
	Duel.SpecialSummon(sg,SUMMON_TYPE_PENDULUM,tp,tp,true,true,POS_FACEUP)
end

--E3
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
function s.cfilter(c,e,tp,eg)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(ARCHE_ETERNADIR)
end
function s.thfilter(c,ev)
	local codes={c:GetCode()}
	return c:IsSetCard(ARCHE_ETERNADIR) and c:IsAbleToHand() and not aux.FindInTable(s.MergedDelayedEventInfotable[ev],nil,table.unpack(codes))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,ev)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,ev)
	if #g>0 then
		Duel.Search(g,tp)
	end
end