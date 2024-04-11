--[[
Number C205: Arch Lich-Lord Thanatos
Numero 205: Arci Signore-Lich Thanatos
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_aeonstride.lua")
Duel.LoadScript("glitchylib_helper.lua")
function s.initial_effect(c)
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),12,5)
	--You can only control 1 "Number C205: Arch Lich-Lord Thanatos".
	c:SetUniqueOnField(1,0,id)
	--[[If this card is Xyz Summoned: Return all banished cards to the GYs, then, if there are 40 or more total cards in the GYs,
	shuffle all cards in both players' hands and GYs into the Decks, and if you do, both players' LP become 8000, also both players draw 5 cards.
	Immediately after this effect resolves, the turn count becomes 1.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_TODECK|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.XyzSummonedCond,nil,s.target,s.operation)
	--c:RegisterEffect(e1)
	--[[During the End Phase: You can detach 2 materials from this card; both players send the top 5 cards of their Deck to the GY.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(nil,aux.DetachSelfCost(2),s.tgtg,s.tgop)
	c:RegisterEffect(e2)
	--[[If this card was Xyz Summoned using "Number 205: Lich-Lord Xe'enafae" as material, it gains the original effects of that monster, also its original DEF becomes 8000.]]
	local matchk=Effect.CreateEffect(c)
	matchk:SetType(EFFECT_TYPE_SINGLE)
	matchk:SetCode(EFFECT_MATERIAL_CHECK)
	matchk:SetValue(s.valcheck)
	matchk:SetLabel(0)
	c:RegisterEffect(matchk)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(CARD_NUMBER_206_XEENAFAE,0))
	e3:SetCategory(CATEGORY_DESTROY|CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,CARD_NUMBER_206_XEENAFAE)
	e3:SetLabelObject(matchk)
	e3:SetFunctions(s.sdcon,nil,s.sdtg,s.sdop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(CARD_NUMBER_206_XEENAFAE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetLabel(CARD_NUMBER_206_XEENAFAE)
	e4:SetCondition(aux.AND(aux.PhylacteryCondition,s.matchkcon))
	e4:SetLabelObject(matchk)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_ADJUST)
	e5:SetRange(LOCATION_MZONE)
	e5:SetLabel(CARD_NUMBER_206_XEENAFAE)
	e5:SetCondition(aux.AND(aux.PhylacteryCondition,s.matchkcon))
	e5:SetOperation(s.adjustop)
	e5:SetLabelObject(matchk)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCode(EFFECT_CANNOT_ACTIVATE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,1)
	e6:SetCondition(aux.AND(aux.TurnPlayerCond(0),aux.PhylacteryCondition,s.matchkcon))
	e6:SetValue(s.actlim)
	e6:SetLabelObject(matchk)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_SET_BASE_DEFENSE)
	e7:SetCondition(s.matchkcon)
	e7:SetValue(8000)
	e7:SetLabelObject(matchk)
	c:RegisterEffect(e7)
end

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,0,PLAYER_ALL,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,5)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetBanishment()
	if Duel.SendtoGrave(g,REASON_EFFECT|REASON_RETURN)>0 and Duel.GetGYCount()>=40 then
		local turnp=Duel.GetTurnPlayer()
		local tg=Duel.GetFieldGroup(0,LOCATION_GRAVE|LOCATION_HAND,LOCATION_GRAVE|LOCATION_HAND):Filter(Card.IsAbleToDeck,nil)
		if #tg>0 then
			Duel.BreakEffect()
			if Duel.ShuffleIntoDeck(tg)>0 then
				for p=turnp,1-turnp,1-2*turnp do
					Duel.SetLP(p,8000)
				end
			end
		end
		for p=turnp,1-turnp,1-2*turnp do
			Duel.Draw(p,5,REASON_EFFECT)
		end
	end
	if Duel.GetTurnCount(nil,true)~=1 then
		Duel.BreakEffect()
		Duel.SetTurnCountCustom(1,e,tp,REASON_RULE)
	end
end

--E2
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) and Duel.IsPlayerCanDiscardDeck(1-tp,5) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,PLAYER_ALL,5)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local turnp=Duel.GetTurnPlayer()
	for p=turnp,1-turnp,1-2*turnp do
		Duel.DiscardDeck(p,5,REASON_EFFECT)
	end
end

--MATCHK
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g and g:IsExists(Card.IsCode,1,nil,CARD_NUMBER_206_XEENAFAE) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.matchkcon(e)
	return e:GetLabelObject():GetLabel()==1
end

--E3
function s.sdcon(e,tp,eg,ep,ev,re,r,rp)
	return s.matchkcon(e) and Duel.IsTurnPlayer(tp) and not aux.PhylacteryCheck(tp)
end
function s.sdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	if c:GetOverlayCount()<2 then
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
		g:AddCard(c)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,PLAYER_ALL,LOCATION_ONFIELD)
		local ct1,ct2=7-Duel.GetHandCount(tp),7-Duel.GetHandCount(1-tp)
		if ct1>0 then
			Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct1)
		end
		if ct2>0 then
			Duel.SetAdditionalOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,ct2)
		end
	end
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local ct=c:GetOverlayCount()
	if ct>=2 and c:CheckRemoveOverlayCard(tp,2,REASON_EFFECT) then
		c:RemoveOverlayCard(tp,2,2,REASON_EFFECT)
	elseif ct<2 and Duel.Destroy(c,REASON_EFFECT)>0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
		if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
			local og=Duel.GetOperatedGroup()
			for tc in aux.Next(og) do
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(STRING_CANNOT_TRIGGER)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1,true)
			end
			local breakchk=false
			local turnp=Duel.GetTurnPlayer()
			for p=turnp,1-turnp,1-2*turnp do
				local ct=7-Duel.GetHandCount(p)
				if ct>0 then
					if not breakchk then
						Duel.BreakEffect()
						breakchk=true
					end
					Duel.Draw(p,ct,REASON_EFFECT)
				end
			end
		end
	end
end

--E5
function s.disfieldeff(typ,code)
	return (typ==EFFECT_TYPE_FIELD and (code==EFFECT_DISABLE or code==EFFECT_CANNOT_DISABLE or code==EFFECT_FORBIDDEN or code==EFFECT_IMMUNE_EFFECT))
		or typ&EFFECT_TYPE_GRANT>0
end
function s.xmateffcon(cond)
	return	function(e,...)
				return e:GetHandler():IsHasEffect(CARD_NUMBER_206_XEENAFAE) and (not cond or cond(e,...))
			end
end
function s.xmateffcon_fix(c,cond)
	return	function(e,...)
				return e:GetHandler():IsHasEffect(CARD_NUMBER_206_XEENAFAE) and (not cond or cond(e,...)) and c:IsAttachedTo(e:GetHandler())
			end
end
function s.matfilter(c)
	return c:IsMonster() and not c:IsCode(CARD_NUMBER_206_XEENAFAE) and not c:HasFlagEffect(CARD_NUMBER_206_XEENAFAE)
end

function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup():Filter(s.matfilter,nil)
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(CARD_NUMBER_206_XEENAFAE,RESET_EVENT|RESETS_STANDARD,0,1)
		local eset=tc:GetEffects()
		for _,effect in ipairs(eset) do
			if effect:GetOwner()==tc then
				local changed=false
				local typ=effect:GetType()
				if effect:GetLabel()~=CARD_NUMBER_206_XEENAFAE and not effect:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) and typ&(EFFECT_TYPE_ACTIVATE|EFFECT_TYPE_XMATERIAL)==0 then
					local fixchk=true
					local range=effect:GetRange()
					local code=effect:GetCode()
					if s.disfieldeff(typ,code) or not (not range or range==0 or range&LOCATION_MZONE>0) then
						fixchk=false
						local ge=effect:Clone()
						ge:SetOwner(c)
						local cond=ge:GetCondition()
						ge:SetCondition(s.xmateffcon_fix(tc,cond))
						ge:SetReset(RESET_EVENT|RESETS_STANDARD_FACEDOWN)
						c:RegisterEffect(ge,true)
					end
					if fixchk then
						changed=true
						typ=(typ&(~EFFECT_TYPE_SINGLE))|EFFECT_TYPE_XMATERIAL
					end
				end
				if changed then
					local ge=effect:Clone()
					ge:SetType(typ)
					local cond=effect:GetCondition()
					ge:SetCondition(s.xmateffcon(cond))
					ge:SetReset(RESET_EVENT|RESETS_STANDARD_FACEDOWN)
					tc:RegisterEffect(ge,true)
				end
			end
		end
	end
end

--E6
function s.actlim(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE and re:GetHandler():IsControler(1-e:GetHandlerPlayer())
end