--Overdrive - Sunlight Yellow
--Overdrive - Giallo Lucesolare
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,9)
	--[[If this card becomes Engaged: You can target 1 Zombie or Fiend monster on the field; destroy it.]]
	c:DriveEffect(0,0,CATEGORY_DESTROY,EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O,EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY,EVENT_ENGAGE,
		nil,
		nil,
		s.destg,
		s.desop
	)
	--[[[-4] (Quick Effect): You can target 1 monster in either GY that was destroyed by battle by a Drive Monster, or destroyed by the effect of a Drive Monster; banish it, then, if you control a Drive Monster, banish 1 other card from your opponent's GY.]]
	c:DriveEffect(-3,1,CATEGORY_REMOVE,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,EVENT_FREE_CHAIN,
		nil,
		nil,
		s.rmtg,
		s.rmop
	)
	--[[[OD]: Special Summon to your field, 1 of your banished Drive Monsters, OR 1 of your opponent's banished monsters.]]
	c:OverDriveEffect(4,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.sptg,
		s.spop
	)
	--[[If you control a LIGHT Drive Monster, you can Special Summon this card (from your hand).]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(5)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT(true)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--[[If this card battles an opponent's monster while you have an Engaged monster, this card's ATK/DEF becomes double its original ATK/DEF, during damage calculation only.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SET_ATTACK_FINAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.statval(CARDDATA_ATTACK))
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e2x:SetValue(s.statval(CARDDATA_DEFENSE))
	c:RegisterEffect(e2x)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regfilter(c)
	if not c:IsReason(REASON_DESTROY) then return false end
	if c:IsReason(REASON_BATTLE) then
		return c:GetReasonCard():IsMonster(TYPE_DRIVE)
	elseif c:IsReason(REASON_EFFECT) then
		return c:GetReasonEffect():IsActiveType(TYPE_DRIVE)
	else
		return false
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.regfilter,nil)
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
end

function s.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND|RACE_ZOMBIE)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
	e:SetLabel(e:GetHandler():GetEngagedID())
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsEngaged() and c:GetEngagedID()==e:GetLabel() and c:IsCanChangeEnergy(3,tp,REASON_EFFECT) and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
		c:ChangeEnergy(3,tp,REASON_EFFECT,true,c)
	end
end

function s.rmfilter(c)
	return c:HasFlagEffect(id) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.Banish(tc)>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsMonster,TYPE_DRIVE),tp,LOCATION_MZONE,0,1,nil) then
		local g=Duel.Group(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local rg=g:Select(tp,1,1,nil)
			if #rg>0 then
				Duel.HintSelection(rg)
				Duel.BreakEffect()
				Duel.Banish(rg)
			end
		end
	end
end

function s.spfilter(c,e,tp)
	if not c:IsFaceup() or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	return c:IsControler(1-tp) or c:IsMonster(TYPE_DRIVE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.spcfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_DRIVE) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.atkcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetEngagedCard(tp) and Duel.GetBattleMonster(1-tp)
end
function s.statval(stat)
	if stat==CARDDATA_ATTACK then
		return	function(e,c)	
					return e:GetHandler():GetBaseAttack()*2
				end
	elseif stat==CARDDATA_DEFENSE then
		return	function(e,c)	
					return e:GetHandler():GetBaseDefense()*2
				end
	end
end