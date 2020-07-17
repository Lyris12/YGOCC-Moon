--Multitask Over_Rider
--Script by XGlitchy30
function c86433598.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c86433598.matfilter,2,2)
	--protection
	local e0x=Effect.CreateEffect(c)
	e0x:SetType(EFFECT_TYPE_SINGLE)
	e0x:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0x:SetRange(LOCATION_MZONE)
	e0x:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e0x:SetCondition(c86433598.indcon)
	e0x:SetValue(1)
	c:RegisterEffect(e0x)
	local e0y=e0x:Clone()
	e0y:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e0y)
	--alternative spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1,86433598)
	e0:SetCondition(c86433598.spcon)
	e0:SetCost(c86433598.spcost)
	e0:SetTarget(c86433598.sptg)
	e0:SetOperation(c86433598.spop)
	c:RegisterEffect(e0)
	--direct attack
	-- local e1=Effect.CreateEffect(c)
	-- e1:SetType(EFFECT_TYPE_SINGLE)
	-- e1:SetCode(EFFECT_DIRECT_ATTACK)
	-- e1:SetCondition(c86433598.directcon)
	-- c:RegisterEffect(e1)
	--activate spell/trap
	-- local e2=Effect.CreateEffect(c)
	-- e2:SetDescription(aux.Stringid(86433598,0))
	-- e2:SetType(EFFECT_TYPE_QUICK_O)
	-- e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	-- e2:SetRange(LOCATION_MZONE)
	-- e2:SetCountLimit(1,80433598)
	-- e2:SetCondition(c86433598.actcon)
	-- e2:SetCost(c86433598.actcost)
	-- e2:SetTarget(c86433598.acttg)
	-- e2:SetOperation(c86433598.actop)
	-- c:RegisterEffect(e2)
	--equip union
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(86433598,1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,81433598)
	e3:SetTarget(c86433598.eqtg)
	e3:SetOperation(c86433598.eqop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(86433598,ACTIVITY_SPSUMMON,c86433598.counterfilter)
end
--filters
function c86433598.matfilter(c)
	return c:IsLinkRace(RACE_CYBERSE)
end
function c86433598.spcheck(c)
	return c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK)
end
function c86433598.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_CYBERSE) and c:GetLevel()<=4 and c:IsAbleToGrave()
end
-- function c86433598.toonfilter(c)
	-- return c:IsFaceup() and c:IsType(TYPE_TOON)
-- end
-- function c86433598.actfilter(c,e,tp,eg,ep,ev,re,r,rp)
	-- if c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost() then
		-- local te=c:GetActivateEffect()
		-- if c:IsType(TYPE_SPELL) and not c:IsType(TYPE_QUICKPLAY) and te:GetCode()==EVENT_FREE_CHAIN and not c:IsHasEffect(17838096) then return false end
		-- if c:CheckActivateEffect(false,true,false)~=nil then return true end
		-- local con=te:GetCondition()
		-- if con and not con(e,tp,eg,ep,ev,re,r,rp) then return false end
		-- local tg=te:GetTarget()
		-- if tg and not tg(e,tp,eg,ep,ev,re,r,rp,0) then return false end
		-- return true
	-- else return false end
-- end
function c86433598.filter(c)
	return ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_UNION)
end
function c86433598.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function c86433598.counterfilter(c)
	return not c:IsType(TYPE_LINK) or not c:IsSetCard(0x86f)
end
--protection
function c86433598.indcon(e)
	return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler(),TYPE_MONSTER)
end
--alternative spsummon
function c86433598.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c86433598.spcheck,1,nil) and ep~=tp and Duel.GetTurnPlayer()==tp 
end
function c86433598.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(86433598,tp,ACTIVITY_SPSUMMON)==0 end
	local fid=e:GetHandler():GetFieldID()
	e:SetLabel(fid)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabel(fid)
	e1:SetTarget(c86433598.sumlimit)
	Duel.RegisterEffect(e1,tp)
end
function c86433598.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabel()~=se:GetLabel() and c:IsType(TYPE_LINK) and c:IsSetCard(0x86f)
end
function c86433598.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) 
		and Duel.IsExistingMatchingCard(c86433598.tgfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c86433598.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp)>0 then
		if Duel.SpecialSummon(c,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)~=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,c86433598.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end
--direct attack
-- function c86433598.directcon(e,tp,eg,ep,ev,re,r,rp)
	-- return Duel.IsExistingMatchingCard(c86433598.toonfilter,tp,0,LOCATION_MZONE,1,nil)
-- end
-- --activate spell/trap
-- function c86433598.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- return Duel.GetAttackTarget()==nil
-- end
-- function c86433598.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- e:SetLabel(100)
	-- if chk==0 then return true end
-- end
-- function c86433598.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- if chk==0 then
		-- if e:GetLabel()==0 then return false end
		-- e:SetLabel(0)
		-- return Duel.IsExistingMatchingCard(c86433598.actfilter,tp,LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
	-- end
	-- e:SetLabel(0)
	-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- local g=Duel.SelectMatchingCard(tp,c86433598.actfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	-- local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- Duel.SendtoGrave(g,REASON_COST)
	-- e:SetCategory(te:GetCategory())
	-- e:SetProperty(te:GetProperty())
	-- local tg=te:GetTarget()
	-- if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	-- te:SetLabelObject(e:GetLabelObject())
	-- e:SetLabelObject(te)
-- end
-- function c86433598.actop(e,tp,eg,ep,ev,re,r,rp)
	-- local te=e:GetLabelObject()
	-- if not te then return end
	-- e:SetLabelObject(te:GetLabelObject())
	-- local op=te:GetOperation()
	-- if op then op(e,tp,eg,ep,ev,re,r,rp) end
-- end
--equip union
function c86433598.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c86433598.filter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(c86433598.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(c86433598.filter),tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c86433598.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,c86433598.filter2,tp,LOCATION_MZONE,0,1,1,nil)
		local tc2=g:GetFirst()
		if tc2 and Duel.Equip(tp,tc,tc2,false) then
			aux.EnableUnionAttribute(tc,c86433598.eqlimit)
			aux.SetUnionState(tc)
			e:SetLabelObject(tc)
			local e0=Effect.CreateEffect(e:GetHandler())
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetCode(EFFECT_EQUIP_LIMIT)
			e0:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD)
			e0:SetValue(c86433598.eqlimit)
			tc:RegisterEffect(e0)
			local atk=tc:GetBaseAttack()
			if atk<0 then atk=0 end
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc2:RegisterEffect(e1)
		end
	end
end
function c86433598.eqlimit(e,c)
	return e:GetOwner()==c
end