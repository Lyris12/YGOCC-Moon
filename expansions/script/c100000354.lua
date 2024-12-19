--[[
Celestial Ruler of the Zodiac
Sovrano Celestiale dello Zodiaco
Card Author: Zerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,13)
	--[[When this card becomes Engaged while you have monsters with 5 or more different Types in your GY: You can Special Summon 1 monster from your GY with a different Type than monsters you
	currently control.]]
	local d1=c:DriveEffect(0,0,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O,nil,EVENT_ENGAGE,
		s.spcon,
		nil,
		s.sptg,
		s.spop
	)
	--[[[+3]: All monsters you control with different Types from each other gain 300 ATK/DEF.]]
	local d2=c:DriveEffect(3,1,CATEGORIES_ATKDEF,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.atktg,
		s.atkop
	)
	--[[[-5]: Target 1 monster your opponent controls that shares a Type with a monster you control; destroy it.]]
	local d3=c:DriveEffect(-5,2,CATEGORY_DESTROY,EFFECT_TYPE_IGNITION,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.destg,
		s.desop
	)
	--[[[OD]: You can activate this effect; during the End Phase of the next turn, you can Special Summon "Celestial Ruler of the Zodiac" from your GY. (This is treated as a Drive Summon.)]]
	local d4=c:OverDriveEffect(3,CATEGORY_SPECIAL_SUMMON|CATEGORY_GRAVE_SPSUMMON,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.regtg,
		s.regop
	)
	--[[If this card is Drive Summoned: You can activate this effect; for the rest of this Duel, during each Standby Phase, Special Summon 1 monster from your Deck that does not share a Type with a
	monster you control, but it cannot have the same Type as a monster that was Special Summoned by this effect, also negate all non-activated effects of the Summoned monster.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,5)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT(EFFECT_COUNT_CODE_DUEL)
	e1:SetFunctions(
		aux.DriveSummonedCond,
		nil,
		s.regtg2,
		s.regop2
	)
	c:RegisterEffect(e1)
end

--D1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetRace)>=5
end
function s.spfilter(c,e,tp,g)
	local race=c:GetRace()
	return race~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not g:IsExists(Card.IsRace,1,nil,race)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(aux.Faceup(Card.IsMonster),tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,g)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local g=Duel.Group(aux.Faceup(Card.IsMonster),tp,LOCATION_MZONE,0,nil)
	local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,g)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end

--D2
function s.filter(c)
	return c:IsFaceup() and c:GetRace()~=0
end
function s.atkfilter(c,g)
	return not g:IsExists(Card.IsRace,1,c,c:GetRace())
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		return #g==1 or g:GetClassCount(Card.GetRace)>1
	end
	local sg=g:Filter(s.atkfilter,nil,g)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,sg,#sg,0,0,300)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil)
	local sg=g:Filter(s.atkfilter,nil,g)
	for tc in aux.Next(sg) do
		tc:UpdateATKDEF(300,300,true,{c,true})
	end
end

--D3
function s.desfilter(c,g)
	local race=c:GetRace()
	return c:IsFaceup() and race~=0 and g:IsExists(Card.IsRace,1,nil,race)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.desfilter(chkc,g) end
	if chk==0 then
		return Duel.IsExists(true,s.desfilter,tp,0,LOCATION_MZONE,1,nil,g)
	end
	local sg=Duel.Select(HINTMSG_DESTROY,true,tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,g)
	Duel.SetCardOperationInfo(sg,CATEGORY_DESTROY)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--D4
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_END)
	e1:OPT()
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetCondition(aux.FALSE)
	e1:SetOperation(s.spop2)
	e1:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,2)
	Duel.RegisterEffect(e1,tp)
	local e2=aux.ManagePyroClockInteraction(c,tp,tp,PHASE_END,2,nil,nil,e1)
	e2:SetDescription(id,4)
end
function s.spfilter2(c,e,tp)
	return c:IsCode(id) and c:IsMonster(TYPE_DRIVE) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_DRIVE,tp,false,false)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 or not Duel.IsExists(false,s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) or not Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then return end
	Duel.Hint(HINT_CARD,tp,id)
	local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #sg>0 then
		Duel.SpecialSummon(sg,SUMMON_TYPE_DRIVE,tp,tp,false,false,POS_FACEUP)
	end
end

--E1
function s.regtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,6)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:OPT()
	e1:SetOperation(s.spop3)
	Duel.RegisterEffect(e1,tp)
end
function s.spfilter3(c,e,tp,g)
	local race=c:GetRace()
	return not Duel.PlayerHasFlagEffectLabel(0,id,race) and race~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not g:IsExists(Card.IsRace,1,nil,race)
end
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil)
	if Duel.GetMZoneCount(tp)<=0 or not Duel.IsExists(false,s.spfilter3,tp,LOCATION_DECK,0,1,nil,e,tp,g) or not Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then return end
	Duel.Hint(HINT_CARD,tp,id)
	local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter3,tp,LOCATION_DECK,0,1,1,nil,e,tp,g)
	if #sg>0 then
		local race=sg:GetFirst():GetRace()
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			for _,rc in aux.BitSplit(race) do
				Duel.RegisterFlagEffect(0,id,0,0,1,rc)
			end
		end
	end
end