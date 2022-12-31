--Not yet finalized values
--Custom constants
TYPE_DECKMASTER		=0x40000000000
TYPE_CUSTOM			=TYPE_CUSTOM|TYPE_DECKMASTER
CTYPE_DECKMASTER	=0x400
CTYPE_CUSTOM		=CTYPE_CUSTOM|CTYPE_DECKMASTER
SUMMON_TYPE_MASTER	=SUMMON_TYPE_SPECIAL+3338

--Custom Type Table
Auxiliary.Deckmasters={} --number as index = card, card as index = function() is_fusion

--overwrite constants
TYPE_EXTRA			=TYPE_EXTRA|TYPE_DECKMASTER

--overwrite functions
local get_type, get_orig_type, get_prev_type_field = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Deckmasters[c] then
		tpe=tpe|TYPE_DECKMASTER
		if not Auxiliary.Deckmasters[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Deckmasters[c] then
		tpe=tpe|TYPE_DECKMASTER
		if not Auxiliary.Deckmasters[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Deckmasters[c] then
		tpe=tpe|TYPE_DECKMASTER
		if not Auxiliary.Deckmasters[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	return tpe
end

--Custom Functions
function Auxiliary.AddOrigDeckmasterType(c,isfusion)
	table.insert(Auxiliary.Deckmasters,c)
	Auxiliary.Customs[c]=true
	local isfusion=isfusion==nil and false or isfusion
	Auxiliary.Deckmasters[c]=function() return isfusion end
end
function Auxiliary.EnableDeckmaster(c,actcon,actcon_alt,mscon,mscustom,penaltycon,penalty)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local typ=c:GetOriginalType()
	--if c:GetOriginalType()&TYPE_PENDULUM==TYPE_PENDULUM or c:GetOriginalType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM then return end
	--Activation from ED
	local act=Effect.CreateEffect(c)
	act:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	act:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	act:SetCode(EVENT_PREDRAW)
	act:SetRange(LOCATION_EXTRA)
	act:SetCondition(Auxiliary.DMActCon(actcon))
	act:SetOperation(Auxiliary.DMFirstAct(typ))
	c:RegisterEffect(act)
	--Protection in Activated State
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_SINGLE)
	e1x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1x:SetCode(EFFECT_IMMUNE_EFFECT)
	e1x:SetRange(LOCATION_SZONE)
	e1x:SetCondition(Auxiliary.CheckDMActivatedState)
	e1x:SetValue(function(e,te)
					return te:GetOwner()~=e:GetOwner()
					end
				)
	c:RegisterEffect(e1x)
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_SINGLE)
	e2x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
	e2x:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2x:SetRange(LOCATION_SZONE)
	e2x:SetCondition(Auxiliary.CheckDMActivatedState)
	e2x:SetValue(1)
	c:RegisterEffect(e2x)
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_SINGLE)
	e3x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
	e3x:SetCode(EFFECT_CANNOT_USE_AS_COST)
	e3x:SetRange(LOCATION_SZONE)
	e3x:SetCondition(Auxiliary.CheckDMActivatedState)
	c:RegisterEffect(e3x)
	--Master Summon
	if mscon~=-1 then
		local ms=Effect.CreateEffect(c)
		ms:SetDescription(aux.Stringid(c:GetOriginalCode(),1))
		ms:SetType(EFFECT_TYPE_FIELD)
		ms:SetCode(EFFECT_SPSUMMON_PROC)
		ms:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		ms:SetRange(LOCATION_SZONE)
		ms:SetCondition(Auxiliary.MasterSummonCon(mscon))
		ms:SetOperation(Auxiliary.MasterSummonOp(mscustom))
		ms:SetValue(SUMMON_TYPE_MASTER)
		c:RegisterEffect(ms)
	end
	local sumlimit=Effect.CreateEffect(c)
	sumlimit:SetType(EFFECT_TYPE_SINGLE)
	sumlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	sumlimit:SetCode(EFFECT_SPSUMMON_CONDITION)
	sumlimit:SetValue(Auxiliary.MasterLimit)
	c:RegisterEffect(sumlimit)
	local neg=Effect.CreateEffect(c)
	neg:SetType(EFFECT_TYPE_SINGLE)
	neg:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	neg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	neg:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
						return e:GetHandler():IsSummonType(SUMMON_TYPE_MASTER)
					end
					)
	c:RegisterEffect(neg)
	--Penalty Effect
	local py=Effect.CreateEffect(c)
	py:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	py:SetCode(EVENT_TURN_END)
	py:SetRange(LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_REMOVED+LOCATION_OVERLAY+LOCATION_HAND+LOCATION_DECK)
	py:SetCondition(Auxiliary.PenaltyCheck(penaltycon))
	py:SetOperation(Auxiliary.PenaltyOperation(penalty))
	c:RegisterEffect(py)
	local reg=Effect.CreateEffect(c)
	reg:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	reg:SetCode(EVENT_LEAVE_FIELD)
	reg:SetOperation(Auxiliary.RegisterPenaltyEffect)
	c:RegisterEffect(reg)
	--Deck Master Replacement
	local rp2=Effect.CreateEffect(c)
	rp2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	rp2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	rp2:SetCode(EVENT_BE_MATERIAL)
	rp2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
						return not e:GetHandler():IsLocation(LOCATION_ONFIELD) and (e:GetHandler():GetPreviousLocation()==LOCATION_MZONE or e:GetHandler():GetPreviousLocation()==LOCATION_SZONE)
						end
					)
	rp2:SetOperation(Auxiliary.RegDeckSubstitute)
	c:RegisterEffect(rp2)
	if actcon_alt~=-1 then
		local rp3=Effect.CreateEffect(c)
		rp3:SetType(EFFECT_TYPE_FIELD)
		rp3:SetCode(EFFECT_SPSUMMON_PROC_G)
		rp3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		rp3:SetRange(LOCATION_EXTRA)
		rp3:SetCondition(Auxiliary.AltMasterSummonCon(typ,actcon_alt))
		rp3:SetOperation(Auxiliary.AltMasterSummonOp(typ))
		rp3:SetValue(SUMMON_TYPE_SPECIAL+1)
		c:RegisterEffect(rp3)
	end
	--keep on field
	local kp=Effect.CreateEffect(c)
	kp:SetType(EFFECT_TYPE_SINGLE)
	kp:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(kp)
	if not Global_DMRedirects then
		Global_DMRedirects=true
		--Redirect
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_TO_DECK_REDIRECT)
		ge1:SetTargetRange(0xff,0xff)
		ge1:SetTarget(Auxiliary.DMToExtra(typ))
		ge1:SetValue(LOCATION_EXTRA)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.GlobalEffect()
		ge2:SetType(EFFECT_TYPE_FIELD)
		ge2:SetCode(EFFECT_TO_HAND_REDIRECT)
		ge2:SetTargetRange(0xff,0xff)
		ge2:SetTarget(Auxiliary.DMToExtra(typ))
		ge2:SetValue(LOCATION_EXTRA)
		Duel.RegisterEffect(ge2,0)
	end
end
--Deck Master Mechanic -- Filters --
function Auxiliary.ActGroupFilter(c,ogcode)
	return c:IsType(TYPE_DECKMASTER) and c:GetOriginalCode()==ogcode
end
function Auxiliary.DeckmasterFilter(c)
	return c:IsFaceup() and (c:GetFlagEffect(3339)>0 or (c:IsType(TYPE_DECKMASTER) and c:IsLocation(LOCATION_MZONE)))
end
--Deck Master First Activation
function Auxiliary.DMActCon(actcon)
	return function (e,tp,eg,ep,ev,re,r,rp)
		return Duel.CheckLocation(tp,LOCATION_SZONE,2) and e:GetHandler():GetFlagEffect(3338)==0 and (not actcon or actcon(e,tp,eg,ep,ev,re,r,rp))
	end
end
function Auxiliary.DMFirstAct(typ)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetFlagEffect(tp,3337)>0 or e:GetHandler():GetFlagEffect(3338)>0 or not Duel.CheckLocation(tp,LOCATION_SZONE,2) or Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),TYPE_DECKMASTER) then return end
		if not Duel.SelectYesNo(tp,aux.Stringid(39759362,2)) then
			local exc=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_DECKMASTER)
			Debug.Message(tostring(#exc))
			for i0 in aux.Next(exc) do
				i0:RegisterFlagEffect(3338,RESET_EVENT+EVENT_CUSTOM+3338,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
			end
			return
		end
		local group=Group.CreateGroup()
		group:KeepAlive()
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_DECKMASTER)
		if #g>0 then
			for i in aux.Next(g) do
				if i:GetOriginalCode()==e:GetHandler():GetOriginalCode() then
					if i:GetFlagEffect(3343)==0 then
						i:RegisterFlagEffect(3343,RESET_EVENT+EVENT_CUSTOM+3343,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
					end
				end
				group:AddCard(i)
			end
		end
		if #group>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local tc=group:Select(tp,1,1,nil):GetFirst()
			if tc:IsLocation(LOCATION_EXTRA) then
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP_ATTACK,true,0x4)
				tc:SetCardData(CARDDATA_TYPE,TYPE_SPELL+TYPE_CONTINUOUS)
				tc:SetCardData(CARDDATA_TYPE,typ)
				--register Original Activation
				tc:RegisterFlagEffect(3339,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
				tc:SetFlagEffectLabel(3339,100)
				--Cost payment
				local m=_G["c"..tc:GetCode()]
				m.DMCost(e,tp,eg,ep,ev,re,r,rp)
			else
				local g2=Duel.GetMatchingGroup(Auxiliary.ActGroupFilter,tp,LOCATION_EXTRA,0,e:GetHandler(),e:GetHandler():GetOriginalCode())
				if #g2>0 then
					for i2 in aux.Next(g2) do
						if i2:GetFlagEffect(3338)~=0 then
							i2:ResetFlagEffect(3338)
						end
					end
				end
			end
		end
		--first turn flag
		Duel.RegisterFlagEffect(tp,3337,RESET_EVENT+EVENT_CUSTOM+3337,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE,1)
	end
end
--Check if the DM is in an Activated State
function Auxiliary.CheckDMActivatedState(e)
	return e:GetHandler():GetFlagEffect(3339)~=0 and e:GetHandler():GetFlagEffect(3340)==0
end
--Master Summon
function Auxiliary.MasterLimit(e,se,sp,st)
	return st&SUMMON_TYPE_MASTER==SUMMON_TYPE_MASTER
end
function Auxiliary.MasterSummonCon(mscon)
	return function (e,c)
		if c==nil then return true end
		return Auxiliary.CheckDMActivatedState(e) and (not mscon or mscon(e,c))
	end
end
function Auxiliary.MasterSummonOp(mscustom)
	return function (e,tp,eg,ep,ev,re,r,rp,c)
		c:RegisterFlagEffect(3340,RESET_EVENT+EVENT_CUSTOM+3340,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
		if mscustom then
			mscustom(e,tp,eg,ep,ev,re,r,rp,c)
		end
	end
end
--Penalty Effect
function Auxiliary.RegisterPenaltyEffect(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(3341,RESET_EVENT+EVENT_CUSTOM+3341,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
end 
function Auxiliary.PenaltyCheck(penaltycon)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(3341)~=0 and not Duel.IsExistingMatchingCard(Auxiliary.DeckmasterFilter,tp,LOCATION_ONFIELD,0,1,nil) and (not penaltycon or penaltycon(e,tp,eg,ep,ev,re,r,rp))
	end
end
function Auxiliary.PenaltyOperation(penalty)
	return function (e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,tp,e:GetHandler():GetOriginalCode())
		if penalty then
			penalty(e,tp,eg,ep,ev,re,r,rp)
		end
		e:GetHandler():ResetFlagEffect(3341)
	end
end
--Deck Master Replacement
function Auxiliary.RegDeckSubstitute(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--if not rc then return end
	rc:RegisterFlagEffect(3339,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
	rc:SetFlagEffectLabel(3339,99)
	Debug.Message('Deck Master has been replaced')
end
function Auxiliary.AltMasterSummonCon(typ,actcon_alt)
	return function (e,c)
		if c==nil then return true end
		local tp=c:GetControler()
		local ft=Duel.CheckLocation(tp,LOCATION_SZONE,2)
		local val=0
		if c:IsType(TYPE_XYZ) then val=c:GetRank()
		elseif c:IsType(TYPE_LINK) then val=c:GetLink()
		elseif c:IsType(TYPE_EVOLUTE) then val=c:GetStage()
		else val=c:GetLevel() end
		return ft and Duel.IsExistingMatchingCard(Auxiliary.AltMasterSummonFilter,tp,LOCATION_MZONE,0,1,nil,typ,val) and c:GetFlagEffect(3343)==0
			and (not actcon_alt or actcon_alt(e,c))
	end
end
function Auxiliary.AltMasterSummonOp(typ)
	return function (e,tp,eg,ep,ev,re,r,rp,c)
		local val=0
		if c:IsType(TYPE_XYZ) then val=c:GetRank()
		elseif c:IsType(TYPE_LINK) then val=c:GetLink()
		elseif c:IsType(TYPE_EVOLUTE) then val=c:GetStage()
		else val=c:GetLevel() end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,Auxiliary.AltMasterSummonFilter,tp,LOCATION_MZONE,0,1,1,nil,typ,val)
		Duel.SendtoGrave(g,REASON_COST)
		if c:IsLocation(LOCATION_EXTRA) then
			Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP_ATTACK,true,0x4)
			c:SetCardData(CARDDATA_TYPE,TYPE_SPELL+TYPE_CONTINUOUS)
			c:SetCardData(CARDDATA_TYPE,typ)
			--register Substitute Activation
			c:RegisterFlagEffect(3339,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
			c:SetFlagEffectLabel(3339,101)
			local g2=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_DECKMASTER)
			if #g2>0 then
				for i in aux.Next(g2) do
					if i:GetOriginalCode()==e:GetHandler():GetOriginalCode() then
						if i:GetFlagEffect(3338)==0 then
							i:RegisterFlagEffect(3338,RESET_EVENT+EVENT_CUSTOM+3338,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
						end
					end
				end
			end
			--Cost payment
			local m=_G["c"..c:GetCode()]
			m.DMCost(e,tp,eg,ep,ev,re,r,rp)
			return
		end
	end
end
function Auxiliary.AltMasterSummonFilter(c,typ,val)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and not Duel.IsExistingMatchingCard(Auxiliary.DeckmasterFilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
		and (c:GetLevel()==val or (c:IsType(TYPE_XYZ) and c:GetRank()==val) or (c:IsType(TYPE_LINK) and c:GetLink()==val) or (c:IsType(TYPE_EVOLUTE) and c:GetStage()==val))
		and ((c:IsType(TYPE_NORMAL) and typ&TYPE_EFFECT~=TYPE_EFFECT) or (c:IsType(TYPE_EFFECT) and not c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_PENDULUM+TYPE_PANDEMONIUM+TYPE_EVOLUTE+TYPE_RITUAL) and typ&TYPE_EFFECT==TYPE_EFFECT)
			or (c:IsType(TYPE_RITUAL) and typ&TYPE_RITUAL==TYPE_RITUAL) or (c:IsType(TYPE_FUSION) and typ&TYPE_FUSION==TYPE_FUSION)
			or (c:IsType(TYPE_SYNCHRO) and typ&TYPE_SYNCHRO==TYPE_SYNCHRO) or (c:IsType(TYPE_LINK) and typ&TYPE_LINK==TYPE_LINK) or (c:IsType(TYPE_EVOLUTE) and typ&TYPE_EVOLUTE==TYPE_EVOLUTE))
end
--Redirect
function Auxiliary.DMToExtra(typ)
	return function(e,c)
		if c:IsType(TYPE_DECKMASTER) and not c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_EVOLUTE) then
			Card.SetCardData(c,CARDDATA_TYPE,typ+TYPE_FUSION)
			return true
		end
		return false
	end
end
