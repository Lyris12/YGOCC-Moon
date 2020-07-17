--Multitasktician BackgroundXLeaker
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,cid.matfilter,2,2)
	--protection
	local e0x=Effect.CreateEffect(c)
	e0x:SetType(EFFECT_TYPE_SINGLE)
	e0x:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0x:SetRange(LOCATION_MZONE)
	e0x:SetCode(EFFECT_IMMUNE_EFFECT)
	e0x:SetCondition(cid.indcon)
	e0x:SetValue(cid.efilter)
	c:RegisterEffect(e0x)
	--alternative spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1,id)
	e0:SetCondition(cid.spcon)
	e0:SetCost(cid.spcost)
	e0:SetTarget(cid.sptg)
	e0:SetOperation(cid.spop)
	c:RegisterEffect(e0)
	--resummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+100)
	e1:SetCondition(cid.sumcon)
	e1:SetTarget(cid.sumtg)
	e1:SetOperation(cid.sumop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
end
--filters
function cid.counterfilter(c)
	return not c:IsType(TYPE_LINK) or not c:IsSetCard(0x86f)
end
function cid.matfilter(c)
	return c:IsLinkRace(RACE_CYBERSE)
end
function cid.spcheck(c)
	return c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK)
end
--protection
function cid.indcon(e)
	return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler(),TYPE_MONSTER)
end
function cid.efilter(e,te)
	local c=e:GetHandler()
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(c) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--alternative spsummon
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.spcheck,1,nil) and ep~=tp and Duel.GetTurnPlayer()==tp 
end
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local fid=e:GetHandler():GetFieldID()
	e:SetLabel(fid)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabel(fid)
	e1:SetTarget(cid.sumlimit)
	Duel.RegisterEffect(e1,tp)
end
function cid.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabel()~=se:GetLabel() and c:IsType(TYPE_LINK) and c:IsSetCard(0x86f)
end
function cid.thfilter(c)
	return c:IsSetCard(0x86f) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) 
		and Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp)>0 then
		if Duel.SpecialSummon(c,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)~=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
--resummon
function cid.sumcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
function cid.sumfilter(c,tp)
	if not c:IsFaceup() or not c:IsType(TYPE_MONSTER) or c:GetSummonType()<=0 then return false end
	return (c:GetSummonType()&SUMMON_TYPE_SPECIAL>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),c:GLGetSetCard(),c:GetType(),c:GetAttack(),c:GetDefense(),c:GLGetLevel(),c:GetRace(),c:GetAttribute(),POS_FACEUP,c:GetControler(),c:GetSummonType()))
		or Duel.IsPlayerCanSummon(tp,c:GetSummonType(),c)
end
function cid.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and cid.sumfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.sumfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) and e:GetHandler():IsAbleToRemove() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,cid.sumfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	local sumtyp=tc:GetFirst():GetSummonType()
	if sumtyp&SUMMON_TYPE_NORMAL>0 then
		Duel.SetOperationInfo(0,CATEGORY_SUMMON,tc,1,0,0)
	end
	if sumtyp&SUMMON_TYPE_SPECIAL>0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
	end
end
function cid.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local sumtyp=tc:GetSummonType()
		if sumtyp&SUMMON_TYPE_NORMAL>0 then
			if tc:IsType(TYPE_DUAL) and not tc:IsDualState() then
				tc:EnableDualState()
			else
				Duel.RaiseEvent(tc,EVENT_SUMMON_SUCCESS,e,REASON_EFFECT,tp,ep,sumtyp)
				Duel.RaiseSingleEvent(tc,EVENT_SUMMON_SUCCESS,e,REASON_EFFECT,tp,ep,sumtyp)
			end
		end
		if sumtyp&SUMMON_TYPE_SPECIAL>0 then
			if Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetCode(),tc:GLGetSetCard(),tc:GetType(),tc:GetAttack(),tc:GetDefense(),tc:GLGetLevel(),tc:GetRace(),tc:GetAttribute(),POS_FACEUP,tc:GetControler(),tc:GetSummonType()) then
				Duel.RaiseEvent(tc,EVENT_SPSUMMON_SUCCESS,e,REASON_EFFECT,tp,ep,sumtyp)
				Duel.RaiseSingleEvent(tc,EVENT_SPSUMMON_SUCCESS,e,REASON_EFFECT,tp,ep,sumtyp)
			end
		end
		if sumtyp&SUMMON_TYPE_FLIP>0 then
			Duel.RaiseEvent(tc,EVENT_FLIP_SUMMON_SUCCESS,e,REASON_EFFECT,tp,ep,sumtyp)
			Duel.RaiseSingleEvent(tc,EVENT_FLIP_SUMMON_SUCCESS,e,REASON_EFFECT,tp,ep,sumtyp)
		end
	end
	if c:IsRelateToEffect(e) then
		if Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)==0 then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabelObject(c)
		e1:SetCondition(cid.retcon)
		e1:SetOperation(cid.retop)
		if Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		end
		Duel.RegisterEffect(e1,tp)
	end
end
function cid.retcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function cid.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end