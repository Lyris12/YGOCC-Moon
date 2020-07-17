--Multitasktician ProcXmanager
--Script by XGlitchy30
function c86433599.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c86433599.matfilter,2,2)
	--cannot be target
	local e0x=Effect.CreateEffect(c)
	e0x:SetType(EFFECT_TYPE_SINGLE)
	e0x:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0x:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e0x:SetRange(LOCATION_MZONE)
	e0x:SetCondition(c86433599.indcon)
	e0x:SetValue(aux.imval1)
	c:RegisterEffect(e0x)
	local e0y=e0x:Clone()
	e0y:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0y:SetValue(aux.tgoval)
	c:RegisterEffect(e0y)
	--alternative spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1,86433599)
	e0:SetCondition(c86433599.spcon)
	e0:SetCost(c86433599.spcost)
	e0:SetTarget(c86433599.sptg)
	e0:SetOperation(c86433599.spop)
	c:RegisterEffect(e0)
	--extra to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86433599,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_DECK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,80433599)
	e1:SetCondition(c86433599.thcon)
	e1:SetTarget(c86433599.thtg)
	e1:SetOperation(c86433599.thop)
	c:RegisterEffect(e1)
	--spsummon
	-- local e2=Effect.CreateEffect(c)
	-- e2:SetDescription(aux.Stringid(86433599,1))
	-- e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	-- e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- e2:SetRange(LOCATION_MZONE)
	-- e2:SetCode(EVENT_SUMMON_SUCCESS)
	-- e2:SetCountLimit(1,81433599)
	-- e2:SetCondition(c86433599.spsumcon)
	-- e2:SetTarget(c86433599.spsumtg)
	-- e2:SetOperation(c86433599.spsumop)
	-- c:RegisterEffect(e2)
	-- --actlimit
	-- local e3=Effect.CreateEffect(c)
	-- e3:SetType(EFFECT_TYPE_FIELD)
	-- e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	-- e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	-- e3:SetRange(LOCATION_MZONE)
	-- e3:SetTargetRange(1,1)
	-- e3:SetValue(c86433599.aclimit)
	-- c:RegisterEffect(e3)
	--register extra summon
	if not c86433599.global_check then
		c86433599.global_check=true
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge:SetCondition(c86433599.registercon)
		ge:SetOperation(c86433599.registerop)
		Duel.RegisterEffect(ge,0)
	end
	Duel.AddCustomActivityCounter(86433599,ACTIVITY_SPSUMMON,c86433599.counterfilter)
end
local index=1
local typelist={}
--register extra summon
function c86433599.registercon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_EXTRA)
end
function c86433599.registerop(e,tp,eg,ep,ev,re,r,rp)
	for i in aux.Next(eg) do
		if i:IsFaceup() and i:IsOnField() and i:IsPreviousLocation(LOCATION_EXTRA) then
			i:RegisterFlagEffect(80433599,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE,1)
		end
	end
end
function c86433599.counterfilter(c)
	return not c:IsType(TYPE_LINK) or not c:IsSetCard(0x86f)
end
--filters
function c86433599.matfilter(c)
	return c:IsLinkRace(RACE_CYBERSE)
end
function c86433599.spcheck(c)
	return c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK)
end
function c86433599.tgfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:IsSetCard(0x118) or c:IsSetCard(0x86f)) and c:IsAbleToGrave()
end
function c86433599.cfilter(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsType(TYPE_EXTRA)
end
function c86433599.cfilter_check(c,tp)
	return c:IsSetCard(0x55d6) and c:IsType(TYPE_MONSTER) and bit.band(c:GetReason(),0x41)==0x41 and c:IsControler(tp) and c:IsAbleToHand() and c:IsLocation(LOCATION_GRAVE)
end
function c86433599.repfilter(c,card)
	return c==card and c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD) and (c:GetDestination()~=LOCATION_HAND or c:GetDestination()~=LOCATION_ONFIELD)
end
function c86433599.allowextragemini(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(86433599)<=0
end
function c86433599.checkns(c)
	return c:GetFlagEffect(80433599)>0
end
function c86433599.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--cannot be target
function c86433599.indcon(e)
	return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler(),TYPE_MONSTER)
end
--alternative spsummon
function c86433599.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c86433599.spcheck,1,nil) and ep~=tp and Duel.GetTurnPlayer()==tp
end
function c86433599.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(86433599,tp,ACTIVITY_SPSUMMON)==0 end
	local fid=e:GetHandler():GetFieldID()
	e:SetLabel(fid)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabel(fid)
	e1:SetTarget(c86433599.sumlimit)
	Duel.RegisterEffect(e1,tp)
end
function c86433599.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabel()~=se:GetLabel() and c:IsType(TYPE_LINK) and c:IsSetCard(0x86f)
end
function c86433599.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) 
		and Duel.IsExistingMatchingCard(c86433599.tgfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c86433599.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp)>0 then
		if Duel.SpecialSummon(c,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)~=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,c86433599.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end
--extra to hand
function c86433599.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c86433599.cfilter,1,nil)
end
function c86433599.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
end
function c86433599.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:FilterSelect(tp,c86433599.cfilter,1,1,nil,tp):GetFirst()
	if tc:IsType(extra) then
		local p,loc,alt=0,0,0
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then p=tp loc=LOCATION_MZONE
		elseif Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then p=tp loc=LOCATION_SZONE
		elseif Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then p=1-tp loc=LOCATION_MZONE
		elseif Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 then p=1-tp loc=LOCATION_SZONE
		else alt=100 end
		if alt==100 then
			Duel.Remove(tc,POS_FACEUP,REASON_RULE)
		else
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
			e1:SetLabelObject(tc)
			e1:SetTargetRange(LOCATION_EXTRA,LOCATION_EXTRA)
			e1:SetTarget(c86433599.debugtofield)
			Duel.RegisterEffect(e1,tp)
			Duel.MoveToField(tc,tp,p,loc,POS_FACEUP_ATTACK,false)
			e1:Reset()
		end
		local typ=tc:GetOriginalType()
		typelist[index]=typ
		index=index+1
		local tpe=typ&TYPE_EXTRA
		tc:SetCardData(CARDDATA_TYPE,typ-tpe)
	end
	if tc and tc:IsAbleToHand() then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
		--reset card to the original status
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EFFECT_SEND_REPLACE)
		e1:SetLabel(index-1)
		e1:SetLabelObject(tc)
		e1:SetTarget(c86433599.reptg)
		e1:SetValue(c86433599.repval)
		Duel.RegisterEffect(e1,tp)
		--allow Normal Summon
		if tc:GetFlagEffect(86433599)<=0 then
			tc:RegisterFlagEffect(86433599,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE,1)
		end
		local nslimit={tc:IsHasEffect(EFFECT_UNSUMMONABLE_CARD)}
		for _,te0 in ipairs(nslimit) do
			local con=te0:GetCondition()
			if con then 
				te0:SetCondition(aux.ModifyCon(con,c86433599.allowextragemini))
				local reset=Effect.CreateEffect(c)
				reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				reset:SetCode(EVENT_ADJUST)
				reset:SetLabelObject(tc)
				reset:SetCondition(c86433599.resetconcon)
				reset:SetOperation(aux.ResetEffectFunc(te0,'condition',con))
				Duel.RegisterEffect(reset,tp)
			else
				te0:SetCondition(c86433599.allowextragemini)
				local reset=Effect.CreateEffect(c)
				reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				reset:SetCode(EVENT_ADJUST)
				reset:SetLabelObject(tc)
				reset:SetCondition(c86433599.resetconcon)
				reset:SetOperation(aux.ResetEffectFunc(te0,'condition',aux.TRUE))
				Duel.RegisterEffect(reset,tp)
			end
		end
	end
end
--reset status
function c86433599.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c86433599.repfilter,1,nil,e:GetLabelObject()) end
	local g=eg:Filter(c86433599.repfilter,nil,e:GetLabelObject())
	local tc=g:GetFirst()
	tc:SetCardData(CARDDATA_TYPE,typelist[e:GetLabel()])
	e:Reset()
	return true
end
function c86433599.repval(e,c)
	return false
end
function c86433599.resetconcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	return not c:IsLocation(LOCATION_HAND) and not c:IsControler(tp)
end
--spsummon
-- function c86433599.spsumcon(e,tp,eg,ep,ev,re,r,rp)
	-- return eg:IsExists(c86433599.checkns,1,nil)
-- end
-- function c86433599.spsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- and Duel.IsExistingMatchingCard(c86433599.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
-- end
-- function c86433599.spsumop(e,tp,eg,ep,ev,re,r,rp)
	-- if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- local g = Duel.SelectMatchingCard(tp,c86433599.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- if g:GetCount()>0 then
		-- Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	-- end
-- end
-- actlimit
-- function c86433599.aclimit(e,re,tp)
	-- local tc=re:GetHandler()
	-- return tc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER) and tc:IsType(TYPE_FLIP) and not tc:IsPosition(POS_FACEUP_DEFENSE) and not tc:IsImmuneToEffect(e)
-- end
--debugtofield
function c86433599.debugtofield(e,c,sump,sumtype,sumpos,targetp,se)
    return c==e:GetLabelObject()
end