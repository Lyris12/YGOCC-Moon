--[[
Unknown HERO Night Raider
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	aux.AddMaterialCodeList(c,100000408)
	c:EnableReviveLimit()
	--"Unknown HERO Masquerade" + 1+ non-Tuner monsters
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,100000408),aux.NonTuner(nil),1)
	--Must first be Synchro Summoned.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	--If this card is Synchro Summoned, or when your opponent activates a Spell/Trap Card or effect while you control this monster (in which case this is a Quick Effect): You can target 3 "HERO" cards in your GY or banishment (including at least 1 "Unknown HERO" card and 1 Spell/Trap); shuffle those targets into the Deck, and if you do, destroy all Spell/Trap Cards your opponent controls, then this card gains 450 ATK/DEF for each Spell/Trap destroyed this way.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DESTROY|CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(
		aux.SynchroSummonedCond,
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetType(EFFECT_TYPE_QUICK_O)
	e2x:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e2x:SetCode(EVENT_CHAINING)
	e2x:SetRange(LOCATION_MZONE)
	e2x:SetFunctions(
		s.negcon,
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e2x)
	--Cards in your opponent's GY and banishment that were destroyed on the field cannot activate their own effects that same turn.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_GB)
	e3:SetTarget(s.disable)
	c:RegisterEffect(e3)
	--At the start of the Battle Phase: Halve the ATK/DEF of all Special Summoned monsters your opponent currently controls.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,1)
	e4:SetCategory(CATEGORIES_ATKDEF)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e4:SetRange(LOCATION_MZONE)
	e4:OPT()
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
s.material_type=TYPE_RITUAL

--E1
function s.tdfilter(c,e)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_HERO) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.rescon(ct)
	return	function(g,e,tp,mg,c)
				local valid = #g%2~=0 or g:IsExists(s.tdfirst,ct,nil)
				return valid,false,nil
			end
end
function s.finishcon(ct)
	return	function(g,e,tp,mg)
				return #g==ct and g:IsExists(s.tdfirst,ct,nil)
			end
end
function s.tdfirst(i)
	if i==1 then
		return	function(c)
					return c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO)
				end
	else
		return	function(c)
					return c:IsST()
				end
	end
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GB,0,nil,e)
	local sg=Duel.GetMatchingGroup(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then
		return #sg>0 and xgl.SelectUnselectGroup(0,g,e,tp,3,3,aux.TRUE,0,nil,nil,nil,nil,nil,{s.tdfirst(1),s.tdfirst(2)})
	end
	local c=e:GetHandler()
	local tg=xgl.SelectUnselectGroup(0,g,e,tp,3,3,s.rescon,1,tp,HINTMSG_TODECK,nil,nil,nil,{s.tdfirst(1),s.tdfirst(2)})
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,#sg*450)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,c,1,0,#sg*450)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsSetCard,nil,ARCHE_HERO)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		local sg=Duel.GetMatchingGroup(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
		if #sg>0 and Duel.Destroy(sg,REASON_EFFECT)>0 then
			local c=e:GetHandler()
			local ct=Duel.GetGroupOperatedByThisEffect(e):GetCount()
			if ct>0 and c:IsRelateToChain() and c:IsFaceup() then
				Duel.BreakEffect()
				c:UpdateATKDEF(ct*450,nil,true,c)
			end
		end
	end
end
--E2X
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_ST) and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end

--E3
function s.disable(e,c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:GetTurnID()==Duel.GetTurnCount()
end

--E4
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.Group(aux.FaceupFilter(Card.IsSpecialSummoned),tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,g,#g,0,0,-2,OPINFO_FLAG_HALVE)
	else
		Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,nil,0,1-tp,LOCATION_MZONE,-2,OPINFO_FLAG_HALVE)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(aux.FaceupFilter(Card.IsSpecialSummoned),tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		tc:HalveATK(true,{c,true})
		tc:HalveDEF(true,{c,true})
	end
end