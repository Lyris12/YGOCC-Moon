--The Horror That Time Forgot
--L'Orrore che il Tempo ha Dimenticato
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,21)
	--[-3]: Target 1 of your Time Leap Monsters that is banished, or in your GY; return it to the Extra Deck.
	local d1=c:DriveEffect(-3,1,CATEGORY_TODECK,EFFECT_TYPE_IGNITION,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.tdtg,
		s.tdop
	)
	--[[[-9]: Target 1 banished monster that was used as Time Leap Material during this turn or the previous one;
	Special Summon it to your field in Defense Position, but banish it when it leaves the field]]
	local d1=c:DriveEffect(-9,2,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.sptg,
		s.spop
	)
	--[OD]: This turn, you can Time Leap Summon a monster in addition to your normal Time Leap Summon.
	local d3=c:OverDriveEffect(3,0,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		nil,
		s.tlop
	)
	--[[If this card is Drive Summoned: You can reveal 1 Time Leap Monster in your Extra Deck; for the rest of this turn,
	you can Time Leap Summon that monster by ignoring its Time Leap Condition, using this card as the material
	(ignoring the Time Leap Material Requirement and the Time Leap Future Requirement of that Time Leap Monster),
	but if you do, that Time Leap Monster is banished face-down when it leaves the field, also it cannot attack your opponent directly this turn.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(5)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.DriveSummonedCond,aux.DummyCost,s.target,s.operation)
	c:RegisterEffect(e1)
	--[[If you Time Leap Summon a Future 7 or higher Time Leap Monster(s) while this card is banished or in your GY (except during the Damage Step):
	You can pay 2700 LP; discard any Engaged Drive Monsters (if any), then add this card to your hand, and if you do, Engage it.]]
	local RMChk=aux.AddThisCardBanishedAlreadyCheck(c,Effect.SetLabelObjectObject,Effect.GetLabelObjectObject)
	local GYChk=aux.AddThisCardInGraveAlreadyCheck(c)
	RMChk:SetLabelObject(GYChk)
	local e2=Effect.CreateEffect(c)
	e2:Desc(7)
	e2:SetCategory(CATEGORY_HANDES|CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GB)
	e2:SetLabelObject(GYChk)
	e2:HOPT()
	e2:SetFunctions(s.thcon,aux.PayLPCost(2700),s.thtg,s.thop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BE_MATERIAL)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
s.PreventWrongRedirect=false

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsReason,nil,REASON_TIMELEAP)
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(id,0))
	end
end

--D1
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsMonster(TYPE_TIMELEAP) and c:IsAbleToExtra()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GB) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GB,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GB,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--D2
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsMonster() and c:HasFlagEffect(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SpecialSummonRedirect(e,tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

--D3
function s.tlop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_IGNORE_TIMELEAP_HOPT)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetOwnerPlayer(tp)
	Duel.RegisterEffect(e1,tp)
end

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() and Duel.IsExists(false,Card.IsMonster,tp,LOCATION_EXTRA,0,1,nil,TYPE_TIMELEAP)
	end
	local g=Duel.Select(HINTMSG_CONFIRM,false,tp,Card.IsMonster,tp,LOCATION_EXTRA,0,1,1,nil,TYPE_TIMELEAP)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.ConfirmCards(1-tp,g)
		Duel.SetTargetCard(tc)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() then
		local eid=e:GetFieldID()
		c:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1,eid)
		
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,6))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_EXTRA)
		e1:SetCondition(Auxiliary.TimeleapCondition(nil,{s.TLfilter,true}))
		e1:SetTarget(Auxiliary.TimeleapTarget(nil,{s.TLfilter,true}))
		e1:SetOperation(Auxiliary.TimeleapOperation(s.TLop))
		e1:SetValue(SUMMON_TYPE_TIMELEAP)
		e1:SetLabel(eid)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.TLfilter(c,e)
	return c:HasFlagEffectLabel(id+100,e:GetLabel())
end
function s.TLop(e,tp,eg,ep,ev,re,r,rp,c)
	aux.TimeleapHOPT(tp)
	local owner=e:GetOwner()
	local e1=Effect.CreateEffect(owner)
	e1:SetDescription(STRING_BANISH_REDIRECT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCondition(function()
		return not s.PreventWrongRedirect
	end)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_EVENT|RESETS_REDIRECT_FIELD)
	c:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(owner)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetCondition(function()
		return not s.PreventWrongRedirect
	end)
	e2:SetOperation(s.bfdop)
	e2:SetReset(RESET_EVENT|RESETS_REDIRECT_FIELD)
	c:RegisterEffect(e2,true)
	local e3=Effect.CreateEffect(owner)
	e3:SetDescription(STRING_CANNOT_DIRECT_ATTACK)
	e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e3:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD|RESET_PHASE|PHASE_END)
	c:RegisterEffect(e3,true)
end
function s.bfdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	s.PreventWrongRedirect=true
	Duel.Remove(c,POS_FACEDOWN,c:GetReason()|REASON_REDIRECT)
	s.PreventWrongRedirect=false
end

--E2
function s.cfilter(c,tp,se)
	local re=c:GetReasonEffect()
	if not (se==nil or not re or re~=se) then return false end
	return c:IsFaceup() and c:IsMonster(TYPE_TIMELEAP) and c:IsFutureAbove(7) and c:IsSummonType(SUMMON_TYPE_TIMELEAP) and c:IsSummonPlayer(tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,e:GetLabelObject():GetLabelObject())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetEngagedCards()
	if chk==0 then
		return (#g==0 or g:FilterCount(Card.IsDiscardable,nil,REASON_EFFECT)==#g) and c:IsAbleToHand() and c:IsCanEngage(tp,true)
	end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,g,#g,0,0)
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetEngagedCards():Filter(Card.IsDiscardable,nil,REASON_EFFECT)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT|REASON_DISCARD)>0 and c:IsRelateToChain() and c:IsAbleToHand() and c:IsCanEngage(tp) then
		Duel.BreakEffect()
	end 
	Duel.SearchAndEngage(c,e,tp,true)
end
