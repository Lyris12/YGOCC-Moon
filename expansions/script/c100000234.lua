--[[
In the Corner of your Eye
Nella Coda del tuo Occhio
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--When your opponent would Special Summon a monster(s), or when your opponent activates an effect that includes Summoning a monster(s): Negate the Summon or activation, and if you do, you can Special Summon 1 Illusion monster from your hand or GY in Defense Position. Immediately after this effect resolves, if you Special Summoned "The Figure in the Mirror" this way, it gains 250 ATK/DEF.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON|CATEGORY_SPECIAL_SUMMON|CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:HOPT()
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	local e1x=Effect.CreateEffect(c)
	e1x:Desc(1)
	e1x:SetCategory(CATEGORY_NEGATE|CATEGORY_SPECIAL_SUMMON|CATEGORY_GRAVE_SPSUMMON)
	e1x:SetType(EFFECT_TYPE_ACTIVATE)
	e1x:SetCode(EVENT_CHAINING)
	e1x:SHOPT()
	e1x:SetFunctions(s.condition2,nil,s.target2,s.activate2)
	c:RegisterEffect(e1x)
	--[[If you activate and resolve the effect of an Illusion monster you control while this card is in your GY: You can banish this card from your GY; apply 1 of the following effects.
	● Destroy 1 card your opponent controls.
	● Banish 1 card from your opponent's GY, face-down.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_DESTROY|CATEGORY_REMOVE|CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE)
	e3:SHOPT()
	e3:SetFunctions(s.rescon,aux.bfgcost,s.restg,s.resop)
	c:RegisterEffect(e3)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.spop(e,tp)
	if Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
			local og=Duel.GetGroupOperatedByThisEffect(e)
			local tc=og:GetFirst()
			if tc and tc:IsCode(CARD_THE_FIGURE_IN_THE_MIRROR) then
				local eid=e:GetFieldID()
				tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1,eid)
				aux.ApplyEffectImmediatelyAfterResolution(s.applyop(tc,eid),e:GetHandler(),e,tp)
			end
		end
	end
end
function s.applyop(tc,eid)
	return	function(e,tp)
				if tc:IsFaceup() and tc:HasFlagEffectLabel(id,eid) then
					tc:UpdateATKDEF(250,nil,0,{e:GetHandler(),true})
				end
			end
	
end

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and aux.NegateSummonCondition()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	s.spop(e,tp)
end

--E1X
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsChainNegatable(ev) and re and (re:IsHasCategory(CATEGORY_SUMMON) or re:IsHasCategory(CATEGORY_SPECIAL_SUMMON))
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		s.spop(e,tp)
	end
end

--E3
function s.rescon(e,tp,eg,ep,ev,re,r,rp)
	local race,p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE,CHAININFO_TRIGGERING_CONTROLER)
	return ep==tp and re and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE and p==tp and race&RACE_ILLUSION>0
end
function s.restg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 or Duel.IsExists(false,Card.IsAbleToRemoveFacedown,tp,0,LOCATION_GRAVE,1,nil,tp)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
function s.resop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0
	local b2=Duel.IsExists(false,aux.Necro(Card.IsAbleToRemoveFacedown),tp,0,LOCATION_GRAVE,1,nil,tp)
	if not b1 and not b2 then return end
	local opt=aux.Option(tp,id,3,b1,b2)
	if opt==0 then
		local g=Duel.Select(HINTMSG_DESTROY,false,tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif opt==1 then
		local g=Duel.Select(HINTMSG_REMOVE,false,tp,aux.Necro(Card.IsAbleToRemoveFacedown),tp,0,LOCATION_GRAVE,1,1,nil,tp)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end