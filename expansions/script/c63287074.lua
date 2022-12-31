--Pecora Nera Sanguinaria
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCondition(s.ddcon)
	e1:SetTarget(s.ddtg)
	e1:SetOperation(s.ddop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.thfil(c)
	return c:IsMonster() and c:IsRace(RACE_BEASTWARRIOR) and c:IsAbleToHand()
end
function s.ddcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:GetAttribute()~=c:GetAttribute()
end
function s.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() and Duel.Destroy(bc,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.thfil,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfil,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			local ct,hct,hg=Duel.Search(g,tp)
			if ct>0 and hct>0 then
				local tc=hg:GetFirst()
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_SUMMON)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetTargetRange(1,0)
				e1:SetTarget(s.sumlimit)
				e1:SetLabel(table.unpack({tc:GetCode()}))
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				Duel.RegisterEffect(e2,tp)
				local e3=e1:Clone()
				e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
				Duel.RegisterEffect(e3,tp)
				Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
			end
		end
	end
end
function s.sumlimit(e,c)
	local codes={e:GetLabel()}
	return c:IsLocation(LOCATION_HAND) and c:IsCode(table.unpack(codes))
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,c)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return g:CheckSubGroup(Group.CheckSameProperty,2,2,Card.GetAttribute) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	e:SetLabel(0)
	local sg=g:SelectSubGroup(tp,Group.CheckSameProperty,false,2,2,Card.GetAttribute)
	if #sg>0 then
		local attributesInGY={}
		for sc in aux.Next(sg) do
			attributesInGY[sc]=sc:GetAttribute()
		end
		if Duel.Remove(sg,POS_FACEUP,REASON_COST)>0 and sg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
			local rg=sg:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
			local attr=0
			for rc in aux.Next(rg) do
				if type(attributesInGY[rc])=="number" then
					attr=attr|(attributesInGY[rc]&(~attr))
				end
			end
			e:SetLabel(attr)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local attr=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToChain(0) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		c:ChangeAttribute(attr,true)
	end
	Duel.SpecialSummonComplete()
end