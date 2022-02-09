--Shadowflame Consort
--Design and code by Kindrindra
local ref=_G['c'..28915260]
local id=28915260
function ref.initial_effect(c)
	--Link Summon
	aux.AddLinkProcedure(c,nil,2,3,ref.lcheck)
	c:EnableReviveLimit()
	--Counter
	if not ref.global_check then
		ref.global_check=true
		c28915260[0]=0
		c28915260[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(ref.resetcount)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAIN_SOLVING)
		ge2:SetRange(LOCATION_SZONE)
		ge2:SetCondition(ref.regcon)
		ge2:SetOperation(ref.regop)
		Duel.RegisterEffect(ge2,0)
	end
	--Can't disable Link Summon if Counterattack is active
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(ref.effcon)
	c:RegisterEffect(e2)
	--Can't respond Link Summon if Counterattack is active
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(ref.effcon)
	e3:SetOperation(ref.spsumsuc)
	c:RegisterEffect(e3)
	--Summon
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id)
	e4:SetTarget(ref.sstg)
	e4:SetOperation(ref.ssop)
	c:RegisterEffect(e4)
	--Draw Cycle
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(2,id+1000)
	e5:SetCondition(ref.drcon)
	e5:SetCost(ref.drcost)
	e5:SetTarget(ref.drtg)
	e5:SetOperation(ref.drop)
	c:RegisterEffect(e5)
	
	--Destruction Replace
	--[[local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(ref.reptg)
	e5:SetValue(ref.repval)
	e5:SetOperation(ref.repop)
	c:RegisterEffect(e5)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e5:SetLabelObject(g)]]
end
function ref.matfilter(c)
	return not c:IsType(TYPE_EFFECT)
end
function ref.lcheck(g,lc)
	return g:GetClassCount(Card.GetCode)==g:GetCount() and g:IsExists(ref.matfilter,1,nil)
end

--Track if Counterattack is active
function ref.resetcount(e,tp,eg,ep,ev,re,r,rp)
	ref[2]=ref[Duel.GetTurnPlayer()]
	--print("Turn Player: ")
	--print(c28915257[2])
	
	ref[Duel.GetTurnPlayer()]=0
	ref[1-Duel.GetTurnPlayer()]=0
end
function ref.regcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
end
function ref.regop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	ref[1-p]=ref[1-p]+1
	--print(c28915257[1-p])
end

--Cannot negate/respond Summon
function ref.effcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=ref[2]
	return ct>3 and e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function ref.spsumsuc(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(ref.chlimit)
end
function ref.chlimit(e,ep,tp)
	return tp==ep
end

--Special Summon
function ref.ssfilter(c,tp)
	return c:IsSetCard(0x729) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),nil,0x4107,0,2400,4,RACE_PYRO,ATTRIBUTE_LIGHT)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local allzones=31
	local oldzones=2424869
	local c=e:GetHandler()
	local linkzone=c:GetLinkedZone(tp)
	--Debug.Message(linkzone)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,allzones-linkzone)>0
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local allzones=31
	local linkzone=e:GetHandler():GetLinkedZone(tp)
	local zone=allzones-linkzone
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		tc:SetStatus(STATUS_NO_LEVEL,false)
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_NORMAL+TYPE_MONSTER)
		e1:SetReset(RESET_EVENT+0x47c0000)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(RACE_PYRO)
		tc:RegisterEffect(e2,true)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e3:SetValue(ATTRIBUTE_LIGHT)
		tc:RegisterEffect(e3,true)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_SET_BASE_ATTACK)
		e4:SetValue(0)
		tc:RegisterEffect(e4,true)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_SET_BASE_DEFENSE)
		e5:SetValue(2400)
		tc:RegisterEffect(e5,true)
		local e6=e1:Clone()
		e6:SetCode(EFFECT_CHANGE_LEVEL)
		e6:SetValue(4)
		tc:RegisterEffect(e6,true)
		if Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP,zone) then
			--Cannot be Link Material
			local e7=Effect.CreateEffect(e:GetHandler())
			e7:SetType(EFFECT_TYPE_SINGLE)
			e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e7:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			e7:SetValue(1)
			e7:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e7,true)
			Duel.SpecialSummonComplete()
		end
	end
end

--Draw
function ref.cfilter(c,zone)
	local seq=c:GetSequence()
	if c:IsLocation(LOCATION_MZONE) then
		if c:IsControler(1) then seq=seq+16 end
	else
		seq=c:GetPreviousSequence()
		if c:GetPreviousControler()==1 then seq=seq+16 end
	end
	return bit.extract(zone,seq)~=0
end
function ref.drcon(e,tp,eg,ep,ev,re,r,rp)
	local zone=Duel.GetLinkedZone(0)+(Duel.GetLinkedZone(1)<<0x10)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(ref.cfilter,1,nil,zone)
end
function ref.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function ref.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function ref.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end

--Destroy Replace
function ref.dfilter(c,g)
	return g:IsContains(c)
end
function ref.repfilter(c)
	return c:IsSetCard(0x729) and c:IsDestructable() and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function ref.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	lg:AddCard(c)
	local g=eg:Filter(ref.dfilter,nil,lg)
	if chk==0 then return (g:GetCount()>0) end
	local cg=Duel.GetMatchingGroup(ref.repfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	if #g>0 and #cg>0 and Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local rg=e:GetLabelObject()
		rg:Clear()
		local retc=g:GetFirst()
		while rtc do
			rtc:RegisterFlagEffect(id,RESET_EVENT+0x1fc0000+RESET_CHAIN,0,1)
			rtc=g:GetNext()
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local scg=cg:Select(tp,1,1,nil)
		rg:Merge(scg)
		return true
	else return false end
end
function ref.rfilter(c)
	return c:GetFlagEffect(id)>0
end
function ref.repval(e,c)
	return ref.rfilter(c)
end
function ref.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if g==nil or #g<=0 then return end
	Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end