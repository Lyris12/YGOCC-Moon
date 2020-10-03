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
	Duel.AnnounceNumber(player,rp)
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

function Auxiliary.EnableRunicPower(c)
	--[[if not runic_global_check then
		runic_global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetRange(0xff)
		ge1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
		ge1:SetOperation(Auxiliary.runicreg)
		c:RegisterEffect(ge1,tp)
	end]]

end
function Auxiliary.runicreg(e,tp,eg,ep,ev,re,r,rp)
	local token=Duel.CreateToken(tp,557)
	Duel.Remove(token,POS_FACEUP,REASON_RULE)
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
	local drhalf = 100
	local chancecapperc = 50
	local chancecap = chancecapperc * 0.01
	return (haste / (haste + 100)) * chancecap
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
	if not haste_global_check then
		haste_global_check=true
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
