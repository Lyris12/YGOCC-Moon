--[[
Crystarion Sage - Contractor of Emerald
Saggio Cristarione - Appaltatore di Smeraldo
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.EnableExtraDeckSummonCountLimit()
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,13)
	--[[[-X]: Special Summon 1 Rock Ritual Monster from your hand with a Level equal to the Energy reduced to activate this effect. (This is treated as a Ritual Summon).]]
	local d1=c:DriveEffect(false,0,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		aux.DummyCost,
		s.sptg,
		s.spop
	)
	--[[[OD]: (Quick Effect): You can target 1 Spell/Trap on the field; destroy that target, and if you do,
	inflict damage to your opponent equal to the Energy this card had before you activated this effect x 500.]]
	local d2=c:OverDriveEffect(1,CATEGORY_DESTROY|CATEGORY_DAMAGE,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.distg,
		s.disop
	)
	--[[If this card is Normal or Special Summoned: You can decrease the Energy of your Engaged "Crystarion" monster by 3, and if you do,
	you can Special Summon 1 Rock monster from your Deck with a Level equal to or lower than the monster you control with the highest Level,
	but you can only Special Summon once from your Extra Deck for the rest of this turn.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCustomCategory(CATEGORY_UPDATE_ENERGY)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[If this card is sent to the GY: You can add 1 "Crystarion" card from your Deck to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.thtg,s.thop)
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
	if chkc then return chkc:IsOnField() and chkc:IsSpellTrapOnField() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsSpellTrapOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectTarget(tp,Card.IsSpellTrapOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	local lp=e:GetHandler():GetOverdriveEnergy()
	Duel.SetTargetParam(lp)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,lp*500)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsSpellTrapOnField() and Duel.Destroy(tc,REASON_EFFECT)>0 then
		local lp=Duel.GetTargetParam()*500
		Duel.Damage(1-tp,lp,REASON_EFFECT)
	end
end

--E1
function s.spfilter2(c,e,tp,lv)
	return c:IsMonster() and c:IsRace(RACE_ROCK) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then
		return en and en:IsMonster() and en:IsSetCard(ARCHE_CRYSTARION) and en:IsCanUpdateEnergy(-3,tp,REASON_EFFECT,e)
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_UPDATE_ENERGY,en,1,INFOFLAG_DECREASE,3)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local en=Duel.GetEngagedCard(tp)
	if en and en:IsMonster() and en:IsSetCard(ARCHE_CRYSTARION) and en:IsCanUpdateEnergy(-3,tp,REASON_EFFECT,e) then
		local mod,diff=en:UpdateEnergy(-3,tp,REASON_EFFECT,true,c,e)
		if diff~=0 and not en:IsImmuneToEffect(mod) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
			if #g==0 then return end
			local mg,lv=g:GetMaxGroup(Card.GetLevel)
			if lv==0 then return end
			local sg=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_DECK,0,nil,e,tp,lv)
			if #sg>0 and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
				Duel.HintMessage(tp,HINTMSG_SPSUMMON)
				local spg=sg:Select(tp,1,1,nil)
				if #spg>0 then
					Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
				end
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e1:SetTargetRange(1,0)
				e1:SetTarget(s.splimit)
				e1:SetReset(RESET_PHASE|PHASE_END)
				Duel.RegisterEffect(e1,tp)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
				e2:SetCode(EVENT_SPSUMMON_SUCCESS)
				e2:SetOperation(s.checkop)
				e2:SetReset(RESET_PHASE|PHASE_END)
				Duel.RegisterEffect(e2,tp)
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_FIELD)
				e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e3:SetCode(92345028)
				e3:SetTargetRange(1,0)
				e3:SetReset(RESET_PHASE|PHASE_END)
				Duel.RegisterEffect(e3,tp)
				Duel.RegisterHint(tp,id,nil,nil,id,4)
			end
		end
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and aux.ExtraDeckSummonCountLimit[sump]<=0
end
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.cfilter,1,nil,tp) then
		aux.ExtraDeckSummonCountLimit[tp]=aux.ExtraDeckSummonCountLimit[tp]-1
	end
	if eg:IsExists(s.cfilter,1,nil,1-tp) then
		aux.ExtraDeckSummonCountLimit[1-tp]=aux.ExtraDeckSummonCountLimit[1-tp]-1
	end
end

--E2
function s.thfilter(c)
	return c:IsSetCard(ARCHE_CRYSTARION) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end