--Frame Driver
--Driver della Struttura
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,4)
	--[[[+2]: If your opponent Normal or Special Summons a face-up monster(s) while this card is Engaged (except during the Damage Step):
	You can shuffle 1 other Drive Monster from your hand into the Deck; that face-up monster(s) cannot attack while this card is Engaged.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,{EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS},s.sumfilter,id,LOCATION_ENGAGED)
	c:DriveEffect(2,0,nil,EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O,EFFECT_FLAG_DELAY,EVENT_CUSTOM+id,
		nil,
		aux.ToDeckCost(aux.MonsterFilter(TYPE_DRIVE),LOCATION_HAND,0,1,1,true),
		s.locktg,
		s.lockop
	)
	--[[[-6]: When your opponent activates a Spell/Trap Card, or monster effect, while you control no Drive Monsters (Quick Effect):
	You can Special Summon this Engaged card and 1 Drive Monster (with its effects negated) from your Deck, except "Frame Driver", and if you do,
	negate the activation, and if you do that, destroy that card.]]
	c:DriveEffect({-6,true},1,CATEGORY_SPECIAL_SUMMON|CATEGORY_NEGATE|CATEGORY_DESTROY,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL,EVENT_CHAINING,
		s.negcon,
		nil,
		s.negtg,
		s.negop
	)
	--Must be either Drive Summoned, or Special Summoned by a card effect.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--If you would increase or decrease the Energy of your Engaged monster to activate its Drive Effect, you can discard this card instead.
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_REPLACE_UPDATE_ENERGY_COST)
	e2:SetRange(LOCATION_HAND)
	e2:SetTargetRange(1,0)
	e2:HOPT()
	e2:SetCondition(s.repcon)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	--[[If a Drive Monster(s) you control would be destroyed by battle or card effect, 
	you can decrease the Energy of your Engaged monster by 1 for each monster that would be destroyed, instead 
	(you must protect all your monsters that would be destroyed, if you use this effect).]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	c:RegisterEffect(e3)
end
function s.sumfilter(c,_,tp)
	return c:IsFaceup() and c:GetSummonPlayer()==1-tp
end
function s.sumchk(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function s.locktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg and eg:IsExists(s.sumchk,1,nil) end
	Duel.SetTargetCard(eg)
end
function s.lockop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsEngaged() then return end
	local g=Duel.GetTargetCards():Filter(Card.IsFaceup,nil)
	if #g<=0 then return end
	local fid,eid=c:GetFieldID(),c:GetEngagedID()
	c:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD,0,1,fid)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_CANNOT_ATTACK)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetLabel(fid,eid)
		e1:SetCondition(s.rcon)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.rcon(e)
	local c=e:GetOwner()
	local fid,eid=e:GetLabel()
	if not c:HasFlagEffectLabel(id+100,fid) or not c:IsEngaged() or c:GetEngagedID()~=eid then
		e:Reset()
		return false
	end
	return true
end

function s.drfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_DRIVE)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_MZONE,0,1,nil) or ep==tp or c:IsStatus(STATUS_DESTROY_CONFIRMED) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return false end
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function s.spfilter(c,e,tp)
	return c:IsMonster(TYPE_DRIVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsEngaged() and Duel.GetMZoneCount(tp)>=2 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,c,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,c:GetLocation()|LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local dc=re:GetHandler()
	if dc:IsRelateToEffect(re) and dc:IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsEngaged() or Duel.GetMZoneCount(tp)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		return
	end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK,0,1,1,c,e,tp)
	if #g>0 then
		local sc=g:GetFirst()
		g:AddCard(c)
		if #g~=2 then return end
		local ct=0
		local fid=c:GetFieldID()
		for tc in aux.Next(g) do
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				ct=ct+1
				if tc==sc then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT|RESETS_STANDARD)
					tc:RegisterEffect(e1,true)
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_DISABLE_EFFECT)
					e2:SetReset(RESET_EVENT|RESETS_STANDARD)
					tc:RegisterEffect(e2,true)
				end
				tc:RegisterFlagEffect(id+200,RESET_EVENT|RESETS_STANDARD,0,1,fid)
			end
		end
		Duel.SpecialSummonComplete()
		g:KeepAlive()
		local rc=re:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE|PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g)
		e1:SetCondition(s.rmcon)
		e1:SetOperation(s.rmop)
		Duel.RegisterEffect(e1,tp)
		if ct>0 and Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
function s.rmfilter(c,fid)
	return c:GetFlagEffectLabel(id+200)==fid
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else
		return true
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.rmfilter,nil,e:GetLabel())
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end

function s.splimit(e,se,sp,st)
	return st&SUMMON_TYPE_DRIVE==SUMMON_TYPE_DRIVE or se:IsHasType(EFFECT_TYPE_ACTIONS)
end

function s.repcon(e,rc,re,rp,ect)
	if not rc then return true end
	local c=e:GetHandler()
	return rc:IsEngaged() and rc:IsControler(tp) and rc~=c and re:IsDriveEffect() and re:IsActivated() and ect~=0
		and c:IsDiscardable(REASON_COST|REASON_REPLACE)
end
function s.repop(e,rc,re,rp,ect)
	Duel.Hint(HINT_CARD,0,id)
	return Duel.SendtoGrave(e:GetHandler(),REASON_COST|REASON_REPLACE|REASON_DISCARD)>0
end

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsMonster(TYPE_DRIVE) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	local ct=eg:FilterCount(s.repfilter,nil,tp)
	if chk==0 then return ct>0 and en and en:IsCanUpdateEnergy(-ct,tp,REASON_EFFECT|REASON_REPLACE) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		en:UpdateEnergy(-ct,tp,REASON_EFFECT|REASON_REPLACE,true,e:GetHandler())
		return true
	else
		return false
	end
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end