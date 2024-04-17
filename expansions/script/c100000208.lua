--[[
Eternadir Lord Kek
Signore Eternadir Kek
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--[[During your Main Phase: You can destroy this card, and if you do, Set 1 "Eternadir" Spell/Trap directly from your Deck,
	also you cannot Special Summon non-Xyz Monsters for the rest of this turn, except by Pendulum Summon.]]
	local p1=Effect.CreateEffect(c)
	p1:Desc(0)
	p1:SetCategory(CATEGORY_DESTROY)
	p1:SetType(EFFECT_TYPE_IGNITION)
	p1:SetRange(LOCATION_PZONE)
	p1:HOPT()
	p1:SetFunctions(nil,nil,s.distg,s.disop)
	c:RegisterEffect(p1)
	--[[If this card is Pendulum Summoned: You can Tribute 2 other "Eternadir" monsters; destroy all Spells/Traps your opponent controls.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.PendulumSummonedCond,s.descost,s.destg,s.desop)
	c:RegisterEffect(e1)
end

--P2
function s.setfilter(c,tp,dc,check)
	if not (c:IsSetCard(ARCHE_ETERNADIR) and c:IsST()) then return false end
	local ignore=false
	if check then
		ignore=not c:IsType(TYPE_FIELD)
		if ignore and Duel.GetLocationCount(tp,LOCATION_SZONE)==0 and not dc:IsInBackrow() then
			return false
		end
	end
	return c:IsSSetable(ignore)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,tp,c,true) end
	Duel.SetCardOperationInfo(c,CATEGORY_DESTROY)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.Destroy(c,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.SSet(tp,tc)
		end
	end
	local e1=Effect.CreateEffect(c)
	e1:Desc(1,id)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sp,st)
	return not c:IsType(TYPE_XYZ) and (st&SUMMON_TYPE_PENDULUM)~=SUMMON_TYPE_PENDULUM
end

--E1
function s.costfilter(c)
	return c:IsSetCard(ARCHE_ETERNADIR) and (c:IsControler(tp) or c:IsFaceup())
end
function s.fselect(g,tp)
	local dg=g:Clone()
	if Duel.IsExistingMatchingCard(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,dg) then
		Duel.SetSelectedCard(g)
		return Duel.CheckReleaseGroup(tp,nil,0,nil)
	else
		return false
	end
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetReleaseGroup(tp):Filter(s.costfilter,c,tp)
	if chk==0 then return g:CheckSubGroup(s.fselect,2,2,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=g:SelectSubGroup(tp,s.fselect,false,2,2,tp)
	aux.UseExtraReleaseCount(rg,tp)
	Duel.Release(rg,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() or Duel.IsExistingMatchingCard(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,nil) end
	local sg=Duel.GetMatchingGroup(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
	if #sg>0 then
		Duel.Destroy(sg,REASON_EFFECT)
	end
end