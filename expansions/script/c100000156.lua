--[[
Crystarion Sage - Contractor of Diamond
Saggio Cristarione - Appaltatore di Diamante
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,13)
	--[[[-X]: Special Summon 1 Rock Ritual Monster from your hand with a Level equal to the Energy reduced to activate this effect. (This is treated as a Ritual Summon).]]
	local d1=c:DriveEffect(false,0,{CATEGORY_SPECIAL_SUMMON,CATEGORY_SPSUMMON_RITUAL_MONSTER},EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		aux.DummyCost,
		s.sptg,
		s.spop
	)
	--[[[OD]: (Quick Effect): You can target 1 face-up monster your opponent controls; negate its effects,
	and if you do, gain LP equal to the Energy this card had before you activated this effect x 500.]]
	local d2=c:OverDriveEffect(1,CATEGORY_DISABLE|CATEGORY_RECOVER,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.distg,
		s.disop
	)
	--[[When your opponent activates a card or effect while you control a face-up "Crystarion" Ritual Monster, and if this card is not Engaged (Quick Effect):
	You can reduce the Energy of your Engaged "Crystarion" Drive Monster by 4, and if you do, negate that effect, then,
	if your Engaged Monster's Energy has been reduced to 0 by this effect, you can Engage this card.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetCustomCategory(CATEGORY_UPDATE_ENERGY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(s.condition,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	--[[If a "Crystarion" Ritual Monster(s) is Ritual Summoned (except during the Damage Step): You can return this card to your hand, and if you do, you can Engage it.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(s.thcon,nil,s.thtg,s.thop)
	c:RegisterEffect(e2)
end
--D1
function s.spfilter(c,e,tp,ec,lv)
	if not c:HasLevel() then return false end
	local ct
	if lv then
		if not c:IsLevel(lv) then return false end
		ct=-lv
	else
		ct=-c:GetLevel()
	end
	return c:IsMonster(TYPE_RITUAL) and c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) and (not ec or ec:IsCanUpdateEnergy(ct,tp,REASON_COST,e))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return e:IsCostChecked() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c)
	end
	local n={}
	for i=1,c:GetEnergy() do
		if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c,i) then
			table.insert(n,i)
		end
	end
	Duel.HintMessage(p,STRING_INPUT_ENERGY)
	local an=Duel.AnnounceNumber(tp,table.unpack(n))
	local _,ct=c:UpdateEnergy(-an,tp,REASON_COST,true,c,e,nil,nil,nil,true)
	e:SetLabel(math.abs(ct))
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetCustomOperationInfo(0,CATEGORY_SPSUMMON_RITUAL_MONSTER,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,nil,e:GetLabel())
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
	end
end

--D2
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	local lp=e:GetHandler():GetOverdriveEnergy()
	Duel.SetTargetParam(lp)
	Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,lp*500)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e) then
		local _,_,res=Duel.Negate(tc,e)
		if res then
			local lp=Duel.GetTargetParam()*500
			Duel.Recover(tp,lp,REASON_EFFECT)
		end
	end
end

--E1
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsSetCard(ARCHE_CRYSTARION)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainDisablable(ev) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) and not e:GetHandler():IsEngaged()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	local rc=re:GetHandler()
	if chk==0 then
		return en and en:IsMonster(TYPE_DRIVE) and en:IsSetCard(ARCHE_CRYSTARION) and en:IsCanUpdateEnergy(-4,tp,REASON_EFFECT,e)
			and (not rc:IsRelateToChain(ev) or not rc:IsDisabled())
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	Duel.SetCustomOperationInfo(0,CATEGORY_UPDATE_ENERGY,en,1,INFOFLAG_DECREASE,4)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local en=Duel.GetEngagedCard(tp)
	if en and en:IsMonster(TYPE_DRIVE) and en:IsSetCard(ARCHE_CRYSTARION) and en:IsCanUpdateEnergy(-4,tp,REASON_EFFECT,e) then
		local ogval=en:GetEnergy()
		local mod,diff=en:UpdateEnergy(-4,tp,REASON_EFFECT,true,c,e)
		if diff~=0 and not en:IsImmuneToEffect(mod) and Duel.NegateEffect(ev) and diff==-ogval
			and c:IsLocation(LOCATION_HAND) and c:IsRelateToChain() and c:IsCanEngage(tp,false,e) and Duel.SelectYesNo(tp,STRING_ASK_ENGAGE) then
			c:Engage(e,tp)
		end
	end
end

--E2
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsSetCard(ARCHE_CRYSTARION) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHand()
	end
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SearchAndEngage(c,e,tp)
	end
end