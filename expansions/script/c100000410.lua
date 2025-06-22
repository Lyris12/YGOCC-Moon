--[[
Unknown HERO Seathreat
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	aux.AddMaterialCodeList(c,100000407)
	c:EnableReviveLimit()
	--"Unknown HERO Masquerade" + 1+ non-Tuner monsters
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,100000407),aux.NonTuner(nil),1)
	--Must first be Synchro Summoned.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	--If this card is Synchro Summoned, or when your opponent Summons a monster(s) while you control this monster (in which case this is a Quick Effect): You can target 2 "HERO" cards in your GY (including at least 1 "Unknown HERO" card) for every 1 monster Summoned; shuffle those targets into the Deck, and if you do, banish those Summoned monsters until the End Phase.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetLabel(0)
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
	e2x:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2x:SetCode(EVENT_SUMMON_SUCCESS)
	e2x:SetRange(LOCATION_MZONE)
	e2x:SetLabel(1)
	e2x:SetFunctions(
		s.negcon,
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e2x)
	e2x:SpecialSummonEventClone(c)
	e2x:FlipSummonEventClone(c)
	--Negate the effects of all cards in your opponent's GY and banishment during your turn only.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_GB)
	e3:SetCondition(aux.TurnPlayerCond(0))
	e3:SetTarget(s.disable)
	c:RegisterEffect(e3)
	--This card can attack all monsters your opponent controls, once each, also banish any monster destroyed by battle with this card.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e5)
end
s.material_type=TYPE_RITUAL

--E1
function s.tdfilter(c,e)
	return c:IsSetCard(ARCHE_HERO) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
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
function s.tdfirst(c)
	return c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local l=e:GetLabel()
	local fg = l~=0 and eg:Filter(Card.IsSummonPlayer,nil,1-tp) or nil
	local ct = l==0 and 2 or 2*#fg
	local rescon = l==0 and aux.TRUE or s.rescon(#fg)
	local ffirst = l==0 and s.tdfirst or nil
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then
		return ((l==0 and c:IsAbleToRemoveTemp(tp))
			or (l==1 and fg:IsExists(Card.IsAbleToRemoveTemp,1,nil,tp) and g:IsExists(s.tdfirst,#fg,nil)))
			and xgl.SelectUnselectGroup(0,g,e,tp,ct,ct,rescon,0,nil,nil,nil,nil,nil,ffirst)
	end
	local finishcon = l~=0 and s.finishcon(ct) or nil
	local tg=xgl.SelectUnselectGroup(0,g,e,tp,ct,ct,rescon,1,tp,HINTMSG_TODECK,finishcon,nil,nil,ffirst)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,0,0)
	if l==0 then
		Duel.SetCardOperationInfo(e:GetHandler(),CATEGORY_REMOVE)
	else
		for fc in aux.Next(fg) do
			fc:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD_FACEDOWN|RESET_CHAIN,0,1,Duel.GetCurrentChain())
		end
		Duel.SetCardOperationInfo(fg,CATEGORY_REMOVE)
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsSetCard,nil,ARCHE_HERO)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		local l=e:GetLabel()
		if l==0 then
			local c=e:GetHandler()
			if c:IsRelateToChain() then
				Duel.BanishUntil(c,e,tp,nil,nil,id)
			end
		else
			local g=eg:Filter(Card.HasFlagEffectLabel,nil,id+100,Duel.GetCurrentChain())
			if #g>0 then
				Duel.BanishUntil(g,e,tp,nil,nil,id)
			end
		end
	end
end
--E2X
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end

--E3
function s.disable(e,c)
	return not c:IsMonster() or c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT
end