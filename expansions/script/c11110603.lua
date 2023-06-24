--Silva, Metalurgos Craftsman
--Silva, Metalurgo Artigiano
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,5)
	--[[[-5]: You can place 1 "Metalurgos Conduction" from your Deck face-up in your Spell & Trap Zone.]]
	c:DriveEffect(-5,0,nil,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.pctg,
		s.pcop
	)
	--[[[OD]: You can banish 1 Drive Monster from your GY, except "Silva, Metalurgos Craftsman";
	add 1 "Metalurgos" Drive Monster from your GY to your hand, and if you do, you can Engage it.]]
	c:OverDriveEffect(1,CATEGORY_TOHAND,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		s.thcost,
		s.thtg,
		s.thop
	)
	--[[Cannot be Drive Summoned, unless you control a face-up "Metalurgos Conduction".]]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetCost(s.spcost)
	c:RegisterEffect(e0)
	--[[You can only Drive Summon "Silva, Metalurgos Craftsman(s)" once per turn.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(aux.DriveSummonedCond)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	--[[If this card is Drive Summoned: You can destroy 1 face-up "Metalurgos" Continuous Spell you control,
	and if you do, Special Summon 1 "Metalurgos" Bigbang Monster from your Extra Deck with a Level equal to or less than the number of monsters you control.
	(This is treated as a Bigbang Summon.)]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetCondition(aux.DriveSummonedCond)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
--FILTERS DE1
function s.pcfilter(c,tp)
	return c:IsCode(CARD_METALURGOS_CONDUCTION) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
--DE1
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
	end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then 
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end

--FILTERS DE2
function s.costfilter(c,tp)
	return c:IsMonster(TYPE_DRIVE) and not c:IsCode(id) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c)
end
function s.thfilter(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsSetCard(ARCHE_METALURGOS) and c:IsAbleToHand()
end
--DE2
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	if #g>0 then
		Duel.Banish(g,nil,REASON_COST)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local check = e:GetLabel()==1 or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		e:SetLabel(0)
		return check
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SearchAndEngage(g:GetFirst(),e,tp)
	end
end

--ME0
function s.spcost(e,c,tp,st)
	if st&SUMMON_TYPE_DRIVE==SUMMON_TYPE_DRIVE then
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_METALURGOS_CONDUCTION),tp,LOCATION_ONFIELD,0,1,nil)
	else
		return true 
	end
end

--ME1
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetOriginalCode()==id and sumtype&SUMMON_TYPE_DRIVE==SUMMON_TYPE_DRIVE
end

--FILTERS ME1
function s.desfilter(c,e,tp,ct)
	if c:IsLocation(LOCATION_MZONE) then
		ct=ct-1
	end
	return c:IsFaceup() and c:IsSpell(TYPE_CONTINUOUS) and c:IsSetCard(ARCHE_METALURGOS) and Duel.IsExistingMatchingCard(s.bbfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,ct,c)
end
function s.bbfilter(c,e,tp,ct,cc)
	return c:IsMonster(TYPE_BIGBANG) and c:IsSetCard(ARCHE_METALURGOS) and c:IsLevelBelow(ct)
		and Duel.GetLocationCountFromEx(tp,tp,cc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false)
end
--ME2
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	local g=Duel.Group(s.desfilter,tp,LOCATION_ONFIELD,0,nil,e,tp,ct)
	if chk==0 then
		return #g>0
	end
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	local g=Duel.Select(HINTMSG_DESTROY,false,tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp,ct)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.bbfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,ct,nil)
		if #sg>0 and Duel.SpecialSummon(sg,SUMMON_TYPE_BIGBANG,tp,tp,false,false,POS_FACEUP)>0 then
			sg:GetFirst():CompleteProcedure()
		end
	end
end