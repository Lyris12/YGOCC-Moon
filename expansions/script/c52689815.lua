--Rescuing Wheel
--Ruota di Salvataggio
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,1)
	--[[[+5] Target 5 of your Drive Monsters that are banished, or in your GY; place them on the bottom of the Deck, in any order, then draw 2 cards.]]
	c:DriveEffect(5,0,CATEGORY_TODECK|CATEGORY_DRAW,EFFECT_TYPE_IGNITION,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.tdtg,
		s.tdop
	)
	--[[-12] (Quick Effect): Target 1 Drive Monster in your GY; Special Summon it, and if you do,
	it is unaffected by your opponent's card effects, until the end of this turn. (This is treated as a Drive Summon).]]
	c:DriveEffect(-12,1,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.sptg,
		s.spop
	)
	--[[If a Drive Monster(s) you control is destroyed by battle or card effect, while this card is in your hand or GY:
	You can activate 1 of these effects, but you cannot activate that same effect of "Rescuing Wheel" for the rest of the turn.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_DESTROYED,s.cfilter,id,LOCATION_HAND|LOCATION_GRAVE,nil,LOCATION_GRAVE)
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT(true)
	e1:SetCost(aux.InfoCost)
	e1:SetTarget(s.target(0))
	e1:SetOperation(s.operation(0))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:Desc(3)
	e2:SetCategory(0)
	e2:HOPT(true)
	e2:SetTarget(s.target(1))
	e2:SetOperation(s.operation(1))
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:Desc(4)
	e3:SetCategory(CATEGORY_REMOVE|CATEGORY_SPECIAL_SUMMON|CATEGORY_GRAVE_SPSUMMON)
	e3:HOPT(true)
	e3:SetTarget(s.target(2))
	e3:SetOperation(s.operation(2))
	c:RegisterEffect(e3)
end
function s.tdfilter(c)
	return c:IsMonster(TYPE_DRIVE) and c:NotBanishedOrFaceup() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED|LOCATION_GRAVE) and c:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,5,nil) and Duel.IsPlayerCanDraw(tp,2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,5,5,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards()
	if #tg>0 and aux.PlaceCardsOnDeckBottom(tp,tg)>0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK|LOCATION_EXTRA) then
		if Duel.IsPlayerCanDraw(tp,2) then
			Duel.BreakEffect()
		end
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end

function s.spfilter(c,e,tp)
	return c:IsMonster(TYPE_DRIVE) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_DRIVE,tp,false,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.SpecialSummon(tc,SUMMON_TYPE_DRIVE,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:CompleteProcedure()
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_UNAFFECTED_BY_OPPONENT_EFFECT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.indval)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
	end
end
function s.indval(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end

function s.cfilter(c,e,tp,eg,_,_,_,_,_,se)
	local h=e:GetHandler()
	return not eg:IsContains(h) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousCustomTypeOnField(TYPE_DRIVE) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and (not h:IsLocation(LOCATION_GRAVE) or (se==nil or c:GetReasonEffect()~=se))
end
function s.dcfilter(c,en,tp,m)
	local ct=c:GetOriginalEnergy()
	return ct>0 and en:IsCanUpdateEnergy(ct*m,tp,REASON_EFFECT)
end
function s.bcheck(opt)
	if opt==0 then
		return	function(c,e,tp)
					return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_DRIVE,tp,false,false)
				end
				
	elseif opt==1 then
		return	function(c,_,tp)
					return (not c:IsLocation(LOCATION_GRAVE) or c:IsAbleToHand()) and c:IsCanEngage(tp)
				end
	
	elseif opt==2 then
		return	function(c,_,tp,eg,en)
					return c:IsAbleToRemove() and en and eg:IsExists(s.dcfilter,1,nil,en,tp,-1) and eg:IsExists(aux.PLChk,1,nil,tp,LOCATION_GRAVE)
				end
	end
end
function s.opinfo(opt)
	if opt==0 then
		return	function(c)
					Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
				end
				
	elseif opt==1 then
		return	function(c,e)
					if e:GetActivateLocation()&LOCATION_GRAVE>0 then
						e:SetCategory(CATEGORY_TOHAND)
						Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
					else
						e:SetCategory(0)
					end
				end
	
	elseif opt==2 then
		return	function(c,_,tp,eg)
					local g=eg:Filter(aux.PLChk,nil,tp,LOCATION_GRAVE)
					Duel.SetTargetCard(g)
					Duel.SetCardOperationInfo(c,CATEGORY_REMOVE)
				end
	end
end
function s.target(opt)
	local check_function = s.bcheck(opt)
	local infos_function = s.opinfo(opt)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				local en=Duel.GetEngagedCard(tp)
				if chk==0 then
					return not c:HasFlagEffect(id+200) and check_function(c,e,tp,eg,en)
				end
				c:RegisterFlagEffect(id+200,RESET_CHAIN,0,1)
				infos_function(c,e,tp,eg)
			end
end
function s.operation(opt)
	if opt==0 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local c=e:GetHandler()
					if Duel.GetMZoneCount(tp)>0 and c:IsRelateToChain() and Duel.SpecialSummon(c,SUMMON_TYPE_DRIVE,tp,tp,false,false,POS_FACEUP)>0 then
						c:CompleteProcedure()
					end
				end
	
	elseif opt==1 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local c=e:GetHandler()
					if e:GetActivateLocation()&LOCATION_GRAVE>0 and c:IsRelateToChain() then
						Duel.SendtoHand(c,nil,REASON_EFFECT)
					end
					if aux.PLChk(c,tp,LOCATION_HAND) and c:IsCanEngage(tp) then
						c:Engage(e,tp)
						if c:IsEngaged() then
							local g=eg:Filter(s.dcfilter,nil,c,tp,1)
							if #g>0 then
								local nums={}
								for tc in aux.Next(g) do
									local energy=tc:GetOriginalEnergy()
									if not aux.FindInTable(nums,energy) then
										table.insert(nums,energy)
									end
								end
								if #nums>0 then
									local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
									c:UpdateEnergy(ct,tp,REASON_EFFECT,true,c)
								end
							end
						end
					end
				end
	
	elseif opt==2 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local c=e:GetHandler()
					if Duel.Banish(c)>0 then
						local en=Duel.GetEngagedCard(tp)
						if en then
							local g=eg:Filter(s.dcfilter,nil,en,tp,-1)
							if #g>0 then
								local nums={}
								for tc in aux.Next(g) do
									local energy=tc:GetOriginalEnergy()
									if not aux.FindInTable(nums,energy) then
										table.insert(nums,energy)
									end
								end
								if #nums>0 then
									local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
									local eff,diff=en:UpdateEnergy(-ct,tp,REASON_EFFECT,true,c)
									if not en:IsImmuneToEffect(eff) and diff~=0 then
										local tg=Duel.GetTargetCards()
										if #tg>0 then
											local fid=c:GetFieldID()
											for tc in aux.Next(tg) do
												tc:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1,fid)
											end
											tg:KeepAlive()
											local e1=Effect.CreateEffect(c)
											e1:Desc(5)
											e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
											e1:SetCode(EVENT_PHASE|PHASE_END)
											e1:SetCountLimit(1)
											e1:SetLabel(fid)
											e1:SetLabelObject(tg)
											e1:SetCondition(s.spscon)
											e1:SetOperation(s.spsop)
											e1:SetReset(RESET_PHASE|PHASE_END)
											Duel.RegisterEffect(e1,tp)
										end
									end
								end
							end
						end
					end
				end
	end
end
					
function s.spsfilter(c,e,tp,lab)
	return aux.PLChk(c,tp,LOCATION_GRAVE) and c:HasFlagEffectLabel(id+100,lab) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.spscon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if Duel.GetMZoneCount(tp)>0 and g:IsExists(aux.NecroValleyFilter(s.spsfilter),1,nil,e,tp,e:GetLabel()) then
		return true
	else
		g:DeleteGroup()
		e:Reset()
		return false
	end
end
function s.spsop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if Duel.GetMZoneCount(tp)>0 then
		local sg=g:Filter(aux.NecroValleyFilter(s.spsfilter),nil,e,tp,e:GetLabel()) 
		if #sg>0 then
			Duel.HintMessage(tp,HINTMSG_SPSUMMON)
			local tg=sg:Select(tp,1,1,nil)
			if #tg>0 then
				Duel.SpecialSummon(tg,0,tp,p,false,false,POS_FACEUP)
			end
		end
	end
	g:DeleteGroup()
end