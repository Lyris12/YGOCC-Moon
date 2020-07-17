--Multitasktician FrameXbooster
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
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
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
	--draw from ED
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetGlitchyCategory(GLCATEGORY_ED_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id+100)
	e1:SetCondition(cid.tmcon)
	e1:SetTarget(cid.tmtg)
	e1:SetOperation(cid.tmop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+200)
	e2:SetCost(cid.spscost)
	e2:SetTarget(cid.spstg)
	e2:SetOperation(cid.spsop)
	c:RegisterEffect(e2)
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
	local ec=te:GetHandler()
	if ec:IsHasCardTarget(c) then return true end
	return te:IsHasType(EFFECT_TYPE_ACTIONS) and te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and c:IsRelateToEffect(te)
		and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
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
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) 
		and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,0,0)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp)>0 then
		if Duel.SpecialSummon(c,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)~=0 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
--draw from ED
function cid.tmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function cid.tmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.GLIsAbleToDrawFromExtra,tp,LOCATION_EXTRA,0,1,nil,tp) and Duel.IsExistingMatchingCard(Card.GLIsAbleToDrawFromExtra,tp,0,LOCATION_EXTRA,1,nil,1-tp) end
	aux.GLSetSpecialInfo(e,GLCATEGORY_ED_DRAW,nil,1,PLAYER_ALL,LOCATION_EXTRA)
end
function cid.tmop(e,tp,eg,ep,ev,re,r,rp)
	if not cid.tmtg(e,tp,eg,ep,ev,re,r,rp,0) then return end
	local sg=Group.CreateGroup()
	sg:KeepAlive()
	for sp=0,1 do
		local g=Duel.GetMatchingGroup(Card.GLIsAbleToDrawFromExtra,sp,LOCATION_EXTRA,0,nil,sp):RandomSelect(sp,1)
		-- if g:GetFirst():IsLocation(LOCATION_EXTRA) then
			-- local p,loc,alt=0,0,0
			-- if Duel.GetLocationCount(sp,LOCATION_MZONE)>0 then p=sp loc=LOCATION_MZONE
			-- elseif Duel.GetLocationCount(sp,LOCATION_SZONE)>0 then p=sp loc=LOCATION_SZONE
			-- elseif Duel.GetLocationCount(1-sp,LOCATION_MZONE)>0 then p=1-sp loc=LOCATION_MZONE
			-- elseif Duel.GetLocationCount(1-sp,LOCATION_SZONE)>0 then p=1-sp loc=LOCATION_SZONE
			-- else alt=100 end
			-- if alt==100 then
				-- Duel.Remove(g:GetFirst(),POS_FACEDOWN,REASON_RULE)
			-- else
				-- local e1=Effect.CreateEffect(e:GetHandler())
				-- e1:SetType(EFFECT_TYPE_FIELD)
				-- e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
				-- e1:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
				-- e1:SetLabelObject(g:GetFirst())
				-- e1:SetTargetRange(LOCATION_EXTRA,0)
				-- e1:SetTarget(cid.debugtofield)
				-- Duel.RegisterEffect(e1,sp)
				-- Duel.MoveToField(g:GetFirst(),sp,p,loc,POS_FACEDOWN_ATTACK,false)
				-- e1:Reset()
			-- end
		-- end
		sg:AddCard(g:GetFirst())
	end
	if #sg>0 then
		local tc=sg:GetFirst()
		while tc do
			local typ=tc:GetOriginalType()
			local fixtyp=(typ&TYPE_PENDULUM>0) and 0 or TYPE_PENDULUM
			local tpe=typ&TYPE_EXTRA
			if tpe>0 then
				tc:SetCardData(CARDDATA_TYPE,typ-tpe+fixtyp)
				Duel.SendtoHand(tc,nil,REASON_EFFECT+REASON_DRAW)
				tc:SetCardData(CARDDATA_TYPE,typ)
			else
				Duel.SendtoHand(tc,nil,REASON_EFFECT+REASON_DRAW)
			end
			tc=sg:GetNext()
		end
	end
end
function cid.debugtofield(e,c,sump,sumtype,sumpos,targetp,se)
    return c==e:GetLabelObject()
end
--spsummon
function cid.spscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function cid.spsfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)	and (c:IsType(TYPE_TOON) or (c:IsRace(RACE_CYBERSE) and c:IsLevelBelow(4)))
end
function cid.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.spsfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cid.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,cid.spsfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		local check=false
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			if not tc:IsType(TYPE_TOON) then
				check=true
				local fid=c:GetFieldID()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
				local n=math.random(1,4)
				if n==1 then
					tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
					local e4=Effect.CreateEffect(c)
					e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					e4:SetCode(EVENT_ADJUST)
					e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
					e4:SetLabel(fid)
					e4:SetLabelObject(tc)
					e4:SetCondition(cid.excon)
					e4:SetOperation(cid.exop)
					Duel.RegisterEffect(e4,tp)
				end
			end
		end
		Duel.SpecialSummonComplete()
		if check then
			local atk=tc:GetTextAttack()
			if atk<0 then atk=0 end
			Duel.Damage(tp,atk,REASON_EFFECT)
		end
	end
end
function cid.excon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
function cid.exop(e,tp,eg,ep,ev,re,r,rp)
	local n=math.random(1,2)
	if n==1 then
		local tc=e:GetLabelObject()
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Exile(tc,REASON_EFFECT)
	end
end