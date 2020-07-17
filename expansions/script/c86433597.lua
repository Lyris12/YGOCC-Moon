--Multitask Operatore
--Script by XGlitchy30
function c86433597.initial_effect(c)
	--Ability Gain
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_BE_MATERIAL)
	e0:SetCondition(c86433597.lkcon)
	e0:SetOperation(c86433597.lkop)
	c:RegisterEffect(e0)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86433597,5))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,86433597)
	e1:SetTarget(c86433597.spsumtg)
	e1:SetOperation(c86433597.spsumop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--link
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(86433597,7))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,81433597)
	e3:SetTarget(c86433597.linktg)
	e3:SetOperation(c86433597.linkop)
	c:RegisterEffect(e3)
end
--filters
function c86433597.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
function c86433597.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
function c86433597.filter(c)
	local ct1,ct2=c:GetUnionCount()
	return c:IsFaceup() and ct2==0
end
function c86433597.spsumfilter(c,e,tp)
	return c:IsSetCard(0x86f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(86433597)
end
function c86433597.sccheck(c)
	return c:IsFaceup() and c:IsSetCard(0x86f)
end
function c86433597.typematch(c,i)
	if i==1 then
		return c:IsType(TYPE_FUSION)
	elseif i==2 then
		return c:IsType(TYPE_SYNCHRO)
	elseif i==3 then
		return c:IsType(TYPE_XYZ)
	elseif i==4 then
		return c:IsType(TYPE_PENDULUM)
	elseif i==5 then
		return c:IsType(TYPE_LINK)
	else
		return false
	end
end
--Ability Properties
function c86433597.toonlimit(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function c86433597.dircon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(c86433597.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		and not Duel.IsExistingMatchingCard(c86433597.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
function c86433597.retcon(e,tp,eg,ep,ev,re,r,rp)
	if not (e:GetLabelObject():GetFlagEffectLabel(86433597)==e:GetLabel()) then
		e:Reset()
		return false
	else return true end
end
function c86433597.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
function c86433597.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c86433597.filter(chkc) end
	if chk==0 then return e:GetHandler():GetFlagEffect(81433597)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(c86433597.filter,tp,LOCATION_MZONE,0,1,c) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,c86433597.filter,tp,LOCATION_MZONE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	c:RegisterFlagEffect(81433597,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
function c86433597.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c86433597.filter(tc) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	if not Duel.Equip(tp,c,tc,false) then return end
	aux.SetUnionState(c)
end
function c86433597.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(81433597)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:RegisterFlagEffect(81433597,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
function c86433597.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end
function c86433597.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0 or bit.band(r,REASON_EFFECT)~=0
end
function c86433597.allowextragemini(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(86433590)<=0
end
function c86433597.matval(e,c,mg)
	return c:IsType(TYPE_LINK)
end
--Ability Gain
function c86433597.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
function c86433597.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local typ=c:GetPreviousTypeOnField()&TYPE_TOON+TYPE_SPIRIT+TYPE_UNION+TYPE_DUAL+TYPE_FLIP
	local id=nil
	if typ==0 then return end
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_TYPE)
	e0:SetValue(typ)
	e0:SetLabel(86433597)
	e0:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e0)
	if typ&TYPE_TOON==TYPE_TOON then
		--Toon Ability
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetOperation(c86433597.toonlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		rc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		rc:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DIRECT_ATTACK)
		e4:SetCondition(c86433597.dircon)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e4)
		rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(86433597,0)) 
	end
	if typ&TYPE_SPIRIT==TYPE_SPIRIT then
		--Spirit Ability
		local fid=c:GetFieldID()
		rc:RegisterFlagEffect(86433597,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(rc)
		e1:SetCondition(c86433597.retcon)
		e1:SetOperation(c86433597.retop)
		Duel.RegisterEffect(e1,tp)
		rc:RegisterFlagEffect(1,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(86433597,1)) 
	end
	if typ&TYPE_UNION==TYPE_UNION then
		--Union Ability
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(30012506,0))
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetCategory(CATEGORY_EQUIP)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTarget(c86433597.eqtg)
		e1:SetOperation(c86433597.eqop)
		e1:SetReset(RESET_EVENT+(RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE))
		rc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(30012506,1))
		e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e2:SetType(EFFECT_TYPE_IGNITION)
		e2:SetRange(LOCATION_SZONE)
		e2:SetTarget(c86433597.sptg)
		e2:SetOperation(c86433597.spop)
		e2:SetReset(RESET_EVENT+(RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE))
		rc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e3:SetValue(c86433597.repval)
		e3:SetReset(RESET_EVENT+(RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE))
		rc:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_EQUIP_LIMIT)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetValue(1)
		e4:SetReset(RESET_EVENT+(RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE))
		rc:RegisterEffect(e4)
		rc:RegisterFlagEffect(2,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(86433597,2)) 
	end
	if typ&TYPE_DUAL==TYPE_DUAL then
		local fidreset=rc:GetFieldID()
		--Gemini Ability
		if rc:GetFlagEffect(86433590)<=0 then
			rc:RegisterFlagEffect(86433590,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE,1)
		end
		--revive limit fix
		local nslimit={rc:IsHasEffect(EFFECT_UNSUMMONABLE_CARD)}
		for _,te0 in ipairs(nslimit) do
			local con=te0:GetCondition()
			if con then 
				te0:SetCondition(aux.ModifyCon(con,c86433597.allowextragemini))
				local reset=Effect.CreateEffect(c)
				reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				reset:SetCode(EVENT_ADJUST)
				reset:SetLabel(fidreset)
				reset:SetLabelObject(rc)
				reset:SetCondition(c86433597.resetconcon)
				reset:SetOperation(aux.ResetEffectFunc(te0,'condition',con))
				Duel.RegisterEffect(reset,tp)
			else
				te0:SetCondition(c86433597.allowextragemini)
				local reset=Effect.CreateEffect(c)
				reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				reset:SetCode(EVENT_ADJUST)
				reset:SetLabel(fidreset)
				reset:SetLabelObject(rc)
				reset:SetCondition(c86433597.resetconcon)
				reset:SetOperation(aux.ResetEffectFunc(te0,'condition',aux.TRUE))
				Duel.RegisterEffect(reset,tp)
			end
		end
		local egroup=global_card_effect_table[c]
		if egroup~=nil then
			for i=1,#egroup do
				local ce=egroup[i]
				if not ce or ce==nil or type(ce)~="userdata" or ce:GetType()==nil then
					table.remove(egroup,i)
				else
					local prop=ce:GetProperty()
					if ce:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
					local con2=ce:GetCondition()
					if ce:GetLabel()~=86433597 then
						if con2 then
							ce:SetCondition(aux.ModifyCon(con2,aux.IsDualState))
							local reset=Effect.CreateEffect(c)
							reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
							reset:SetCode(EVENT_ADJUST)
							reset:SetLabel(fidreset)
							reset:SetLabelObject(rc)
							reset:SetCondition(c86433597.resetconcon)
							reset:SetOperation(aux.ResetEffectFunc(ce,'condition',con2))
							Duel.RegisterEffect(reset,tp)
						else
							ce:SetCondition(aux.IsDualState)
							local reset=Effect.CreateEffect(c)
							reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
							reset:SetCode(EVENT_ADJUST)
							reset:SetLabel(fidreset)
							reset:SetLabelObject(rc)
							reset:SetCondition(c86433597.resetconcon)
							reset:SetOperation(aux.ResetEffectFunc(ce,'condition',aux.TRUE))
							Duel.RegisterEffect(reset,tp)
						end
					end
				end
			end
		end
		--
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DUAL_SUMMONABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCondition(aux.DualNormalCondition)
		e2:SetValue(TYPE_NORMAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_REMOVE_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3)
		rc:RegisterFlagEffect(3,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(86433597,3)) 
	end
	if typ&TYPE_FLIP==TYPE_FLIP then 
		rc:RegisterFlagEffect(4,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(86433597,4)) 
	end
end
--spsummon
function c86433597.spsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c86433597.spsumfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c86433597.spsumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c86433597.spsumfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			if not c:IsFaceup() and not c:IsLocation(LOCATION_MZONE) then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
			local op=Duel.SelectOption(tp,aux.Stringid(86433597,0),aux.Stringid(86433597,1),aux.Stringid(86433597,2),aux.Stringid(86433597,3),aux.Stringid(86433597,4))
			if op==0 then
				local e0=Effect.CreateEffect(c)
				e0:SetType(EFFECT_TYPE_SINGLE)
				e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
				e0:SetCode(EFFECT_ADD_TYPE)
				e0:SetValue(TYPE_TOON)
				e0:SetLabel(86433597)
				e0:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e0)
				c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(86433597,0))
			elseif op==1 then
				local e0=Effect.CreateEffect(c)
				e0:SetType(EFFECT_TYPE_SINGLE)
				e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
				e0:SetCode(EFFECT_ADD_TYPE)
				e0:SetValue(TYPE_SPIRIT)
				e0:SetLabel(86433597)
				e0:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e0)
				c:RegisterFlagEffect(1,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(86433597,1))
			elseif op==2 then
				local e0=Effect.CreateEffect(c)
				e0:SetType(EFFECT_TYPE_SINGLE)
				e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
				e0:SetCode(EFFECT_ADD_TYPE)
				e0:SetValue(TYPE_UNION)
				e0:SetLabel(86433597)
				e0:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e0)
				c:RegisterFlagEffect(2,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(86433597,2))
			elseif op==3 then
				local e0=Effect.CreateEffect(c)
				e0:SetType(EFFECT_TYPE_SINGLE)
				e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
				e0:SetCode(EFFECT_ADD_TYPE)
				e0:SetValue(TYPE_DUAL)
				e0:SetLabel(86433597)
				e0:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e0)
				c:RegisterFlagEffect(3,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(86433597,3))
			else
				local e0=Effect.CreateEffect(c)
				e0:SetType(EFFECT_TYPE_SINGLE)
				e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
				e0:SetCode(EFFECT_ADD_TYPE)
				e0:SetValue(TYPE_FLIP)
				e0:SetLabel(86433597)
				e0:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e0)
				c:RegisterFlagEffect(4,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(86433597,4)) 
			end
		end
	end
end
--link
function c86433597.lkfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsSpecialSummonable(SUMMON_TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,1-tp,true,true)
end
function c86433597.linktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local el={}
		local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
		local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE+LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED+LOCATION_DECK+LOCATION_FZONE,c)
		g:Merge(g2)
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e0:SetRange(LOCATION_MZONE)
		e0:SetCode(EFFECT_MUST_BE_LMATERIAL)
		e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e0:SetTargetRange(1,1)
		c:RegisterEffect(e0)
		local e0x=Effect.CreateEffect(c)
		e0x:SetType(EFFECT_TYPE_SINGLE)
		e0x:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e0x:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
		e0x:SetRange(LOCATION_MZONE)
		e0x:SetValue(c86433597.matval)
		c:RegisterEffect(e0x)
		table.insert(el,e0)
		table.insert(el,e0x)
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			tc:RegisterEffect(e1)
			table.insert(el,e1)
		end
		local res=Duel.IsExistingMatchingCard(c86433597.lkfilter,tp,0,LOCATION_EXTRA,1,nil,e,tp)
		for _,e in ipairs(el) do
			e:Reset()
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_EXTRA)
end
function c86433597.linkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local el={}
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
	local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE+LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED+LOCATION_DECK+LOCATION_FZONE,c)
	g:Merge(g2)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_MUST_BE_LMATERIAL)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,1)
	c:RegisterEffect(e0)
	local e0x=Effect.CreateEffect(c)
	e0x:SetType(EFFECT_TYPE_SINGLE)
	e0x:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0x:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e0x:SetRange(LOCATION_MZONE)
	e0x:SetValue(c86433597.matval)
	c:RegisterEffect(e0x)
	table.insert(el,e0)
	table.insert(el,e0x)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		tc:RegisterEffect(e1)
		table.insert(el,e1)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xg=Duel.SelectMatchingCard(1-tp,c86433597.lkfilter,tp,0,LOCATION_EXTRA,1,1,nil,e,tp)
	local tc=xg:GetFirst()
	if tc then
		Duel.SpecialSummonRule(1-tp,tc,SUMMON_TYPE_LINK)
	end
	for _,e in ipairs(el) do
		e:Reset()
	end
end
function c86433597.resetconcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	return not c:IsOnField() or (c:IsOnField() and (not c:IsFaceup() or c:GetFieldID()~=e:GetLabel()))
end