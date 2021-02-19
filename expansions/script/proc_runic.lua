
--created by SlientKnight, coded by Kinny
--Not yet finalized values
--Custom constants

--Track
g_RP={0,0}
g_RP[0]=0
g_RP[1]=0

--Custom Functions
function Duel.GetRP(player)
	return g_RP[player]
end
function Duel.SetRP(player, rp)
	_r = g_RP
	g_RP[player] = rp
	--Duel.Hint(HINT_NUMBER,player,rp)
	return _r
end
function Duel.CheckRPCost(player, rp)
	return g_RP[player] >= rp
end
function Duel.PayRPCost(player, rp)
	value = g_RP[player] - rp
	Duel.SetRP(player,value)
end
function Duel.GainRP(player, rp)
	value = g_RP[player] + rp
	Duel.SetRP(player,value)
end

function Card.GetRuneslots(c)
	return c:GetFlagEffectLabel(80808881)
end

function Card.AddRuneslots(c,number)
	if c:GetFlagEffect(80808881) == 0 then
		c:RegisterFlagEffect(80808881,RESETS_STANDARD+RESETS_REDIRECT,0,1)
		c:SetFlagEffectLabel(80808881,0)
	end
	local current = c:GetFlagEffectLabel(80808881)
	if current < 1 then
		aux.Add_Runeslots(c,0)
	end
	c:SetFlagEffectLabel(80808881,math.min(current+number,3))
end
	
function Card.RemoveRuneslots(c,number)
	local current = c:GetRuneslots()
	if number >= current then number = current end
	if current == 0 then return end
	c:SetFlagEffectLabel(80808881,current-number)
end

function Auxiliary.Add_Runeslots(c,number)
	c:RegisterFlagEffect(1000,nil,0,1)
	c:SetFlagEffectLabel(1000,number)
	local Runeslots=Effect.CreateEffect(c)
	Runeslots:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	Runeslots:SetCode(EVENT_ADJUST)
	Runeslots:SetRange(LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_OVERLAY)
	Runeslots:SetOperation(Auxiliary.Runeslotsstart)
	c:RegisterEffect(Runeslots)
end

function Auxiliary.Runeslotsstart(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:ResetFlagEffect(80808881)
	c:SetFlagEffectLabel(80808881,0)
	local number = c:GetFlagEffectLabel(1000)
	if c:GetFlagEffect(80808881) == 0 then
		c:RegisterFlagEffect(80808881,nil,0,1)
		c:SetFlagEffectLabel(80808881,0)
	end
	c:SetFlagEffectLabel(80808881,number)
end

function Auxiliary.Ability_Infused(c)
	local INFUSED1=Effect.CreateEffect(c)
	INFUSED1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	INFUSED1:SetCode(EVENT_BE_MATERIAL)
	INFUSED1:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	INFUSED1:SetCountLimit(1,c:GetCode()*732)
	INFUSED1:SetOperation(aux.INFUSED1op)
	c:RegisterEffect(INFUSED1)
	local INFUSED2=Effect.CreateEffect(c)
	INFUSED2:SetCategory(CATEGORY_CONTROL)
	INFUSED2:SetType(EFFECT_TYPE_IGNITION)
	INFUSED2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	INFUSED2:SetCost(aux.INFUSED2cost)
	INFUSED2:SetOperation(aux.INFUSED2op)
	c:RegisterEffect(INFUSED2)
end

function Auxiliary.INFUSED1op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	rc:AddRuneslots(1)
end

function Auxiliary.INFUSED2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

function Auxiliary.INFUSED2op(e,tp,eg,ep,ev,re,r,rp)
   local atk=e:GetHandler():GetAttack()
   if atk<0 then atk=0 end
   Duel.GainRP(tp,atk)
end
function Auxiliary.I_Am_Runic(c)
	local RUNICS=Effect.CreateEffect(c)
	RUNICS:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	RUNICS:SetCode(EVENT_TO_GRAVE)
	RUNICS:SetOperation(Auxiliary.runicbanish)
	c:RegisterEffect(RUNICS)
end

function Auxiliary.runicbanish(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Exile(c,REASON_EFFECT)
end 

function Auxiliary.I_Am_Paragon(c)
	local Paragon=Effect.CreateEffect(c)
	Paragon:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	Paragon:SetRange(LOCATION_EXTRA)	
	Paragon:SetCode(EVENT_ADJUST)
	Paragon:SetCondition(Auxiliary.sdcon)
	Paragon:SetOperation(Auxiliary.sdop)
	c:RegisterEffect(Paragon)
	local Paragon2=Effect.CreateEffect(c)
	Paragon2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	Paragon2:SetRange(LOCATION_EXTRA)   
	Paragon2:SetCode(EVENT_CUSTOM+80808880)
	Paragon2:SetCondition(Auxiliary.sdcon)
	Paragon2:SetOperation(Auxiliary.sdop)
	c:RegisterEffect(Paragon2)
end

function Auxiliary.sdfilter(c)
	return c:IsSetCard(0x8ff5)
end

function Auxiliary.sdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.sdfilter,e:GetHandlerPlayer(),LOCATION_EXTRA,0,2,nil)
end

function Auxiliary.sdop(e)
	Duel.SendtoGrave(e:GetHandler(),REASON_RULE)
end

function Auxiliary.Normal_Runic_Attach(c)
	local RUNICS2=Effect.CreateEffect(c)
	RUNICS2:SetType(EFFECT_TYPE_IGNITION)
	RUNICS2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	RUNICS2:SetRange(LOCATION_EXTRA)
	RUNICS2:SetTarget(Auxiliary.runicmattg)
	RUNICS2:SetOperation(Auxiliary.runicmatop)
	c:RegisterEffect(RUNICS2)
end

function Auxiliary.runicmatfilter(c)
	Debug.Message(c:GetCode())
	Debug.Message(c:GetRuneslots())
	aux.Add_Runeslots(c,0)
	c:AddRuneslots(0)
	return c:IsFaceup() and c:GetRuneslots()>=1 
end

function Auxiliary.runicmattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and Auxiliary.runicmatfilter(chkc) end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		and Duel.IsExistingTarget(Auxiliary.runicmatfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Auxiliary.runicmatfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
end

function Auxiliary.runicmatop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,Group.FromCards(c))
		tc:RemoveRuneslots(1)
	end
end













--  New Stats


				---------
				--HASTE--
				---------
g_Haste={0,0}
g_Haste[0]=0
g_Haste[1]=0

-- functions

function Duel.GetHaste(player)
	return g_Haste[player]
end

function Duel.GainHaste(player, haste)
	value = g_Haste[player] + haste
	Duel.SetHaste(player,value)
end

function Duel.LoseHaste(player, haste)
	value = g_Haste[player] - haste
	Duel.SetHaste(player,value)
end

function Duel.GetHasteChance(player)
	local haste=Duel.GetHaste(player)
	return haste/100
end

function Duel.SetHaste(player, haste)
	_r = g_Haste
	g_Haste[player] = haste
	return _r
end

--proc
local f=Card.IsRelateToEffect
Card.IsRelateToEffect=function(c,e)
	if c:GetFlagEffect(888666)>0 then return true end
	return f(c,e)
end

function Auxiliary.EnableHaste(c)
	local haste=Effect.CreateEffect(c)
	haste:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	haste:SetCode(EVENT_CHAINING)
	haste:SetRange(LOCATION_EXTRA+LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_ONFIELD+LOCATION_REMOVED+LOCATION_PZONE+LOCATION_FZONE)
	haste:SetCondition(Auxiliary.hastecondition)
	haste:SetTarget(Auxiliary.hastetarget)
	haste:SetOperation(Auxiliary.hasteactivate)
	c:RegisterEffect(haste)
	local haste2=Effect.CreateEffect(c)
	haste2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	haste2:SetCode(EVENT_CHAINING)
	haste2:SetRange(LOCATION_EXTRA+LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_ONFIELD+LOCATION_REMOVED+LOCATION_PZONE+LOCATION_FZONE)
	haste2:SetCondition(aux.haste2condition)
	haste2:SetOperation(aux.haste2activate)
	c:RegisterEffect(haste2)	
end

function Auxiliary.hastecondition(e,tp,eg,ep,ev,re,r,rp)
	local tp = e:GetHandlerPlayer()
	local hastechance=Duel.GetHasteChance(tp)
	local check = math.random()
	return rp==tp
		and check < hastechance
		-- and re:IsHasType(EFFECT_TYPE_ACTIVATE) 
		and not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and not re:IsHasCategory(CATEGORY_NEGATE) 
		and re:GetOperation() ~= nil
end

function Auxiliary.hastetarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ftg=re:GetTarget()
	if chkc then return ftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	if chk==0 then return  e:GetOperation()~=re:GetOperation() and (not ftg or ftg(e,tp,eg,ep,ev,re,r,rp,chk)) end
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	end
	if ftg then
		ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end

function Auxiliary.hasteactivate(e,tp,eg,ep,ev,re,r,rp)
	local fop=re:GetOperation()
	if fop then fop(e,tp,eg,ep,ev,re,r,rp) end
end

--

function Auxiliary.haste2condition(e,tp,eg,ep,ev,re,r,rp)
	local tp = e:GetHandlerPlayer()
	return rp==tp and re:GetOperation() ~= nil
end

function Auxiliary.haste2activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if tc:GetFlagEffect(888666)==0 then
		tc:RegisterFlagEffect(888666,RESET_EVENT+RESETS_STANDARD,0,0,0,1)
		local haste2=Effect.CreateEffect(tc)
		haste2:SetType(EFFECT_TYPE_QUICK_O)
		haste2:SetRange(LOCATION_EXTRA+LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_ONFIELD+LOCATION_REMOVED+LOCATION_PZONE+LOCATION_FZONE)
		haste2:SetCode(EVENT_CHAINING)
		haste2:SetReset(RESET_EVENT+RESETS_STANDARD)
		haste2:SetCondition(aux.haste3Cond)
		haste2:SetTarget(aux.haste2target)
		haste2:SetOperation(aux.haste3activate)
		tc:RegisterEffect(haste2)
		if tc:IsType(TYPE_SPELL+TYPE_TRAP) then
			local haste3=haste2:Clone()
			Duel.RegisterEffect(haste3,tp)
		end
	end
end

function Auxiliary.haste3Cond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local hastechance=Duel.GetHasteChance(tp)
	local check = math.random()
	return check < hastechance and 
			c:GetCode() == rc:GetCode() and c==rc and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end

function Auxiliary.haste2target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ftg=re:GetTarget()
	if chkc then return ftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	if chk==0 then return e:GetOperation()~=re:GetOperation() and (not ftg or ftg(e,tp,eg,ep,ev,re,r,rp,chk)) end
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	end
	if ftg then
		ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end

function Auxiliary.haste3activate(e,tp,eg,ep,ev,re,r,rp)
	local fop=re:GetOperation()
	if fop then fop(e,tp,eg,ep,ev,re,r,rp) end
end



				-----------
				--Utility--
				-----------
g_Util={0,0}
g_Util[0]=0
g_Util[1]=0

function Duel.GetUtil(player)
	return g_Util[player]
end

function Duel.GetUtilRed(player)
	local Util=Duel.GetUtil(player)
	local drhalf = 100
	local damagereductioncapperc = 90
	local damagereductioncap = damagereductioncapperc * 0.01
	return 1 - (Util / (Util + 100)) * damagereductioncap
end

function Duel.GetUtilAmp(player)
	local Util=Duel.GetUtil(player)
	local drhalf = 100
	local damagereductioncapperc = 180
	local damagereductioncap = damagereductioncapperc * 0.01
	return 1 + ((Util / (Util + 100)) * damagereductioncap)
end

function Duel.SetUtil(player, Util)
	_r = g_Util
	g_Util[player] = Util
	return _r
end

function Duel.GainUtil(player, Util)
	value = g_Util[player] + Util
	Duel.SetUtil(player,value)
end

function Duel.LoseUtil(player, Util)
	value = g_Util[player] - Util
	Duel.SetUtil(player,Util)
end

--effect

function Auxiliary.EnableUtil(c)
	local tp = Card.GetOwner(c)
	if not util_global_check then
		util_global_check=true
		local util1=Effect.CreateEffect(c)
		util1:SetType(EFFECT_TYPE_FIELD)
		util1:SetCode(EFFECT_CHANGE_DAMAGE)
		util1:SetTargetRange(0,1)
		util1:SetRange(LOCATION_EXTRA+LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_ONFIELD+LOCATION_REMOVED)
		util1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		util1:SetValue(aux.Utilval1)
		c:RegisterEffect(util1)
		local util2=Effect.CreateEffect(c)
		util2:SetType(EFFECT_TYPE_FIELD)
		util2:SetCode(EFFECT_CHANGE_DAMAGE)
		util2:SetRange(LOCATION_EXTRA+LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_ONFIELD+LOCATION_REMOVED)
		util2:SetTargetRange(1,0)
		util2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		util2:SetValue(aux.Utilval2)
		c:RegisterEffect(util2)
	end
end

function Auxiliary.Utilcondition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_BATTLE
end

function Auxiliary.Utilval1(e,re,dam,r,rp,rc)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	local utilamp = Duel.GetUtilAmp(tp)
	return dam * utilamp
end

function Auxiliary.Utilval2(e,re,dam,r,rp,rc)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	local utilred = Duel.GetUtilRed(tp)
	return dam * utilred
end

--


				-----------
				--Augment--
				-----------
g_Aug={0,0}
g_Aug[0]=0
g_Aug[1]=0

function Duel.GetAugment(player)
	return g_Aug[player]
end

function Duel.SetAugment(player, Aug)
	_r = g_Aug
	g_Aug[player] = Aug
	return _r
end

function Duel.GainAugment(player, Aug)
	value = g_Aug[player] + Aug
	Duel.SetAugment(player,value)
end

function Duel.LoseAugment(player, Aug)
	value = g_Aug[player] - Aug
	Duel.SetAugment(player,Aug)
end
