--Dimenticalgia Falso Ritorno
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetLabel(0)
	e2:SetCost(cid.spcost)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
end
--filters
function cid.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf45) and c:IsAbleToDeck()
end
function cid.cfilter(c,tp)
	if not c:IsType(TYPE_MONSTER) or not c:IsAbleToRemoveAsCost() then return false end
	local lv=c:GetLevel()
	if c:IsType(TYPE_XYZ) then
		lv=c:GetRank()
	elseif c:IsType(TYPE_LINK) then
		lv=c:GetLink()
	end
	return c:IsSetCard(0xf45) and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0xf45,0x21,c:GetAttack(),c:GetDefense(),lv,c:GetRace(),c:GetAttribute())
end
--Activate
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3)
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND,0,2,e:GetHandler()) 
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetMatchingGroup(cid.filter,p,LOCATION_HAND,0,nil)
	if g:GetCount()>=2 then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
		local sg=g:Select(p,2,2,nil)
		Duel.ConfirmCards(1-p,sg)
		if Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)~=0 and sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
			local shf=sg:Filter(Card.IsLocation,nil,LOCATION_DECK)
			if shf:GetCount()>0 then
				for sp=0,1 do
					if shf:IsExists(Card.IsControler,1,nil,sp) then
						Duel.ShuffleDeck(sp)
					end
				end
			end
			Duel.Draw(p,3,REASON_EFFECT)
		end
	end
end
--special summon
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local cg=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),tp)
	if cg:GetCount()>0 then
		Duel.HintSelection(cg)
		if Duel.Remove(cg,POS_FACEUP,REASON_COST)~=0 then
			cg:KeepAlive()
			e:SetLabelObject(cg)
			e:SetLabel(0)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
		end
	end
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject():GetFirst()
	local lv=tc:GetLevel()
	if tc:IsType(TYPE_XYZ) then
		lv=tc:GetRank()
	elseif tc:IsType(TYPE_LINK) then
		lv=tc:GetLink()
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
	and Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetCode(),0xf45,0x21,tc:GetAttack(),tc:GetDefense(),lv,tc:GetRace(),tc:GetAttribute()) then
		c:AddMonsterAttribute(TYPE_EFFECT,tc:GetAttribute(),tc:GetRace(),lv,tc:GetAttack(),tc:GetDefense())
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetValue(tc:GetCode())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2,true)
		c:CopyEffect(tc:GetCode(),RESET_EVENT+RESETS_STANDARD)
		Duel.SpecialSummonComplete()
	end
end