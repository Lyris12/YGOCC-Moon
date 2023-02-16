--Erbabruciata
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:Quick(false,0,CATEGORY_ATKCHANGE,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP,false,LOCATION_HAND,{1,0},aux.ExceptOnDamageCalc,aux.ToGraveSelfCost,s.target,s.operation)
	c:DestroyedFieldTrigger(nil,false,1,CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE,false,LOCATION_GRAVE,{1,1},s.spcon,aux.SSLimit(s.counterfilter2,2,true),s.sptg,s.spop)
	--
	c:SSCounter(s.counterfilter)
end
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.counterfilter2(c)
	return not c:IsLocation(LOCATION_EXTRA) or c:IsAttribute(ATTRIBUTE_FIRE)
end

function s.filter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local info =	function(g)
						return Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0,700)
					end
	return aux.Target(s.filter,LOCATION_MZONE,0,1,1,nil,false,info)(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		tc:UpdateATK(700,RESET_PHASE+PHASE_END,c)
		local e2=tc:FirstTimeProtection(false,false,true,true,RESET_PHASE+PHASE_END,c)
		e2:SetProperty(e2:GetProperty()+EFFECT_FLAG_CLIENT_HINT)
		e2:Desc(4)
	end
end

function s.cf(c)
	return c:GetPreviousTypeOnField()&TYPE_ST>0 and c:IsPreviousControler(tp) and c:GetPreviousLocation()&LOCATION_ONFIELD>0
		and (c:GetPreviousPosition()&POS_FACEUP>0 or c:GetPreviousLocation()~=LOCATION_MZONE)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and aux.EventGroupCond(s.cf,1)(e,tp,eg,ep,ev,re,r,rp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.rmf(c)
	return c:IsST() and c:IsAbleToRemove()
end
function s.spcheck(e,tp)
	return	function(sg)
					return Duel.GetMZoneCount(tp,sg)>=#sg and Duel.IsExistingMatchingCard(s.spf,tp,LOCATION_DECK,0,#sg,sg,e,tp)
				end
end
function s.spf(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) and Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Group(s.rmf,tp,LOCATION_GRAVE,0,nil)
		aux.GCheckAdditional=s.spcheck(e,tp)
		if g:CheckSubGroup(aux.TRUE,1) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			local max = (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) and 1 or nil
			local rg=g:SelectSubGroup(tp,aux.TRUE,false,1,max)
			if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
				local ct=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED):FilterCount(Card.IsFaceup,nil)
				if Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct then
					local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spf,tp,LOCATION_DECK,0,ct,ct,nil,e,tp)
					if #sg>0 then
						Duel.SpecialSummonRedirect(e,sg,0,tp,tp,false,false,POS_FACEUP)
					end
				end
			end
		end
		aux.GCheckAdditional=nil
	end
end